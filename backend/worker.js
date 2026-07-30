const JSON_HEADERS = {
  "content-type": "application/json; charset=utf-8",
  "access-control-allow-origin": "*",
  "access-control-allow-headers": "content-type",
  "access-control-allow-methods": "GET,POST,OPTIONS",
};

export default {
  async fetch(request, env) {
    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: JSON_HEADERS });
    }

    const url = new URL(request.url);

    try {
      if (request.method === "GET" && url.pathname === "/health") {
        return json({ ok: true });
      }

      if (request.method === "GET" && url.pathname === "/polls/active") {
        const playerId = (url.searchParams.get("player_id") || "").trim();
        if (!isValidId(playerId, 128)) {
          return json({ error: "invalid_player_id" }, 400);
        }
        return await getActivePollResponse(env.DB, playerId);
      }

      if (request.method === "POST" && url.pathname === "/votes") {
        return await submitVote(request, env.DB);
      }

      return json({ error: "not_found" }, 404);
    } catch (error) {
      console.error("BOX DEFENSE voting API error", error);
      return json({ error: "internal_error" }, 500);
    }
  },
};

async function submitVote(request, db) {
  let body;
  try {
    body = await request.json();
  } catch {
    return json({ error: "invalid_json" }, 400);
  }

  const pollId = String(body?.poll_id || "").trim();
  const optionId = String(body?.option_id || "").trim();
  const playerId = String(body?.player_id || "").trim();

  if (!isValidId(pollId, 96) || !isValidId(optionId, 96) || !isValidId(playerId, 128)) {
    return json({ error: "invalid_vote" }, 400);
  }

  const poll = await db
    .prepare(
      `SELECT id, option_a_id, option_b_id
       FROM polls
       WHERE id = ?1
         AND status = 'open'
         AND datetime(starts_at) <= datetime('now')
         AND datetime(ends_at) > datetime('now')
       LIMIT 1`
    )
    .bind(pollId)
    .first();

  if (!poll) {
    return json({ error: "poll_not_open" }, 409);
  }

  if (optionId !== poll.option_a_id && optionId !== poll.option_b_id) {
    return json({ error: "invalid_option" }, 400);
  }

  await db
    .prepare(
      `INSERT INTO votes (poll_id, player_id, option_id, created_at)
       VALUES (?1, ?2, ?3, datetime('now'))
       ON CONFLICT(poll_id, player_id) DO NOTHING`
    )
    .bind(pollId, playerId, optionId)
    .run();

  return await getPollResponse(db, pollId, playerId);
}

async function getActivePollResponse(db, playerId) {
  const poll = await db
    .prepare(
      `SELECT id
       FROM polls
       WHERE status = 'open'
         AND datetime(starts_at) <= datetime('now')
         AND datetime(ends_at) > datetime('now')
       ORDER BY datetime(starts_at) DESC
       LIMIT 1`
    )
    .first();

  if (!poll) {
    return json({ error: "no_active_poll" }, 404);
  }

  return await getPollResponse(db, poll.id, playerId);
}

async function getPollResponse(db, pollId, playerId) {
  const poll = await db
    .prepare(
      `SELECT id, question,
              option_a_id, option_a_text,
              option_b_id, option_b_text,
              ends_at, show_results
       FROM polls
       WHERE id = ?1
       LIMIT 1`
    )
    .bind(pollId)
    .first();

  if (!poll) {
    return json({ error: "poll_not_found" }, 404);
  }

  const totalsResult = await db
    .prepare(
      `SELECT option_id, COUNT(*) AS vote_count
       FROM votes
       WHERE poll_id = ?1
       GROUP BY option_id`
    )
    .bind(pollId)
    .all();

  const totals = new Map();
  for (const row of totalsResult.results || []) {
    totals.set(String(row.option_id), Number(row.vote_count || 0));
  }

  const playerVote = await db
    .prepare(
      `SELECT option_id
       FROM votes
       WHERE poll_id = ?1 AND player_id = ?2
       LIMIT 1`
    )
    .bind(pollId, playerId)
    .first();

  return json({
    id: poll.id,
    question: poll.question,
    ends_text: formatEndsText(poll.ends_at),
    show_results: Boolean(poll.show_results),
    player_vote: playerVote?.option_id || "",
    options: [
      {
        id: poll.option_a_id,
        text: poll.option_a_text,
        votes: totals.get(String(poll.option_a_id)) || 0,
      },
      {
        id: poll.option_b_id,
        text: poll.option_b_text,
        votes: totals.get(String(poll.option_b_id)) || 0,
      },
    ],
  });
}

function formatEndsText(value) {
  const end = new Date(`${value}Z`);
  const remainingMs = end.getTime() - Date.now();
  if (!Number.isFinite(remainingMs) || remainingMs <= 0) {
    return "VOTE CLOSED";
  }

  const totalMinutes = Math.ceil(remainingMs / 60000);
  const days = Math.floor(totalMinutes / 1440);
  const hours = Math.floor((totalMinutes % 1440) / 60);
  const minutes = totalMinutes % 60;

  if (days > 0) return `ENDS IN ${days}D ${hours}H`;
  if (hours > 0) return `ENDS IN ${hours}H ${minutes}M`;
  return `ENDS IN ${minutes}M`;
}

function isValidId(value, maxLength) {
  return value.length > 0 && value.length <= maxLength && /^[A-Za-z0-9_-]+$/.test(value);
}

function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: JSON_HEADERS,
  });
}
