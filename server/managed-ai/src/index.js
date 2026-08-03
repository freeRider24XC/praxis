import { createServer } from 'node:http';

const port = Number(process.env.PORT || 8787);
const sharedToken = process.env.PRAXIS_AI_SHARED_TOKEN || '';
const openAiApiKey = process.env.OPENAI_API_KEY || '';
const openAiBaseUrl = (process.env.OPENAI_BASE_URL || 'https://api.openai.com/v1')
  .replace(/\/$/, '');
const openAiModel = process.env.OPENAI_MODEL || 'gpt-4o-mini';
const openAiTimeoutMs = Number(process.env.OPENAI_TIMEOUT_MS || 30000);
const providerName = process.env.OPENAI_PROVIDER_NAME || inferProviderName(openAiBaseUrl);
const apiProtocol = process.env.OPENAI_API_PROTOCOL || inferApiProtocol(openAiBaseUrl);

function inferProviderName(baseUrl) {
  if (baseUrl.includes('minimax.io')) {
    return 'MiniMax';
  }
  if (baseUrl.includes('minimaxi.com')) {
    return 'MiniMax';
  }
  if (baseUrl.includes('openai.com')) {
    return 'OpenAI';
  }
  return 'OpenAI-compatible';
}

function inferApiProtocol(baseUrl) {
  if (baseUrl.includes('/anthropic')) {
    return 'anthropic';
  }
  return 'openai';
}

function json(response, statusCode, payload) {
  response.writeHead(statusCode, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  });
  response.end(JSON.stringify(payload));
}

function unauthorized(response) {
  json(response, 401, { error: 'Unauthorized' });
}

function notFound(response) {
  json(response, 404, { error: 'Not found' });
}

function methodNotAllowed(response) {
  json(response, 405, { error: 'Method not allowed' });
}

function parseJsonBody(request) {
  return new Promise((resolve, reject) => {
    let raw = '';
    request.on('data', (chunk) => {
      raw += chunk;
    });
    request.on('end', () => {
      if (!raw) {
        resolve({});
        return;
      }
      try {
        resolve(JSON.parse(raw));
      } catch (error) {
        reject(error);
      }
    });
    request.on('error', reject);
  });
}

function isAuthorized(request) {
  if (!sharedToken) {
    return true;
  }
  const header = request.headers.authorization || '';
  return header === `Bearer ${sharedToken}`;
}

function addDays(days) {
  const now = new Date();
  now.setDate(now.getDate() + days);
  return now.toISOString().slice(0, 10);
}

function mockPlanGoal(goalText) {
  return {
    domain: '职业发展',
    goal: {
      title: goalText || '新的成长目标',
      description: `围绕“${goalText || '新的成长目标'}”建立一个可执行的 1-3 个月推进目标。`,
      targetDate: addDays(90),
    },
    milestones: ['定义成功标准', '完成第一周推进', '产出一个可展示成果'],
    project: {
      name: `${goalText || '新的成长目标'} 执行项目`,
      description: '把目标从概念变成一组可执行动作。',
    },
    todos: [
      {
        title: `定义${goalText || '目标'}的成功标准`,
        description: '先写清楚结果和验收标准。',
        dueDate: addDays(1),
        priority: 'high',
      },
      {
        title: `安排${goalText || '目标'}的第一周行动`,
        description: '把最小下一步排进本周。',
        dueDate: addDays(2),
        priority: 'high',
      },
      {
        title: `完成${goalText || '目标'}的第一个可见动作`,
        description: '先拿到一个能感受到推进的小成果。',
        dueDate: addDays(3),
        priority: 'medium',
      },
    ],
    followUpQuestions: ['你这周最稳定的可投入时间段是什么？'],
  };
}

function mockReviewDay(payload) {
  const tomorrow = (payload.topPriorityTomorrow || '').trim();
  const blockers = (payload.blockers || '').trim();
  return {
    summary: (payload.whatDone || '').trim()
      ? '今天已经有了明确推进，主线没有停下来。'
      : '今天的推进还不够明显，但你已经为下一步留下了线索。',
    focus: tomorrow
      ? `明天只盯住“${tomorrow}”，先把这一步做完。`
      : blockers
        ? `明天先降低“${blockers}”带来的阻力，再恢复推进。`
        : '明天先完成一个 20 分钟以内的最小行动。',
  };
}

function mockSuggestToday(payload) {
  const firstTodo = Array.isArray(payload.todos) ? payload.todos[0] : null;
  return {
    suggestion: firstTodo?.title
      ? `今天先推进“${firstTodo.title}”，它最直接影响当前主线。`
      : '今天先完成一个最小但明确的动作，把推进感建立起来。',
  };
}

function normalizeMilestones(items) {
  return (Array.isArray(items) ? items : [])
    .map((item) => {
      if (typeof item === 'string') {
        return item.trim();
      }
      if (item && typeof item === 'object') {
        return String(item.title || item.name || item.description || '').trim();
      }
      return '';
    })
    .filter(Boolean);
}

function normalizeTodos(items) {
  return (Array.isArray(items) ? items : [])
    .map((item, index) => {
      if (!item || typeof item !== 'object') {
        return {
          title: `执行步骤 ${index + 1}`,
          description: '',
          dueDate: addDays(index + 1),
          priority: 'medium',
        };
      }
      return {
        title: String(item.title || item.name || `执行步骤 ${index + 1}`).trim(),
        description: String(item.description || '').trim(),
        dueDate: String(item.dueDate || addDays(index + 1)).trim(),
        priority: String(item.priority || 'medium').trim().toLowerCase(),
      };
    })
    .filter((item) => item.title);
}

function normalizeGoalPlanShape(raw, payload) {
  const goalText = payload.goalText || '新的成长目标';
  const goal =
    raw?.goal && typeof raw.goal === 'object'
      ? {
          title: String(raw.goal.title || goalText).trim(),
          description: String(
            raw.goal.description ||
              `围绕“${goalText}”建立一个可执行的 1-3 个月推进目标。`,
          ).trim(),
          targetDate: String(raw.goal.targetDate || addDays(90)).trim(),
        }
      : {
          title: goalText,
          description: String(raw?.goal || `围绕“${goalText}”建立一个可执行的 1-3 个月推进目标。`).trim(),
          targetDate: addDays(90),
        };

  const project =
    raw?.project && typeof raw.project === 'object'
      ? {
          name: String(raw.project.name || raw.project.title || `${goal.title} 项目`).trim(),
          description: String(raw.project.description || '').trim(),
        }
      : {
          name: String(raw?.project || `${goal.title} 项目`).trim(),
          description: '',
        };

  const followUpQuestions = (Array.isArray(raw?.followUpQuestions)
    ? raw.followUpQuestions
    : []
  )
    .map((item) => String(item || '').trim())
    .filter(Boolean);

  return {
    domain: String(raw?.domain || payload.focusedDomainId || '职业发展').trim(),
    goal,
    milestones: normalizeMilestones(raw?.milestones),
    project,
    todos: normalizeTodos(raw?.todos),
    followUpQuestions,
  };
}

async function callOpenAiJson({ systemPrompt, userPayload }) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), openAiTimeoutMs);

  try {
    const response = await fetch(`${openAiBaseUrl}/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${openAiApiKey}`,
      },
      body: JSON.stringify({
        model: openAiModel,
        response_format: { type: 'json_object' },
        temperature: 0.4,
        messages: [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: JSON.stringify(userPayload) },
        ],
      }),
      signal: controller.signal,
    });

    if (!response.ok) {
      const text = await response.text();
      throw new Error(`Upstream AI request failed: ${response.status} ${text}`);
    }

    const data = await response.json();
    const content = data?.choices?.[0]?.message?.content;
    if (!content) {
      throw new Error('Upstream AI returned empty content');
    }
    return JSON.parse(content);
  } finally {
    clearTimeout(timer);
  }
}

function extractFirstJsonObject(text) {
  const trimmed = String(text || '').trim();
  if (!trimmed) {
    throw new Error('Empty model content');
  }

  try {
    return JSON.parse(trimmed);
  } catch (_) {
    const start = trimmed.indexOf('{');
    const end = trimmed.lastIndexOf('}');
    if (start === -1 || end === -1 || end <= start) {
      throw new Error('Model response did not contain JSON');
    }
    return JSON.parse(trimmed.slice(start, end + 1));
  }
}

async function callAnthropicJson({ systemPrompt, userPayload }) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), openAiTimeoutMs);

  try {
    const response = await fetch(`${openAiBaseUrl}/v1/messages`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${openAiApiKey}`,
      },
      body: JSON.stringify({
        model: openAiModel,
        max_tokens: 1024,
        system: `${systemPrompt}\n\n只输出严格 JSON 对象，不要 markdown，不要解释，不要思考过程。`,
        messages: [
          {
            role: 'user',
            content: [
              {
                type: 'text',
                text: JSON.stringify(userPayload),
              },
            ],
          },
        ],
      }),
      signal: controller.signal,
    });

    if (!response.ok) {
      const text = await response.text();
      throw new Error(`Upstream AI request failed: ${response.status} ${text}`);
    }

    const data = await response.json();
    const textBlock = Array.isArray(data?.content)
      ? data.content.find((block) => block?.type === 'text' && typeof block?.text === 'string')
      : null;
    return extractFirstJsonObject(textBlock?.text);
  } finally {
    clearTimeout(timer);
  }
}

async function handlePlanGoal(payload) {
  if (!openAiApiKey) {
    return mockPlanGoal(payload.goalText);
  }

  const request = {
    systemPrompt: [
      '你是 Praxis 的目标规划助手。',
      '输出严格 JSON，不要 markdown，不要解释。',
      '返回字段必须包含 domain, goal, milestones, project, todos, followUpQuestions。',
      'todos 必须是本周内可以开始执行的最小行动。',
    ].join('\n'),
    userPayload: payload,
  };

  try {
    const raw =
      apiProtocol === 'anthropic'
        ? await callAnthropicJson(request)
        : await callOpenAiJson(request);
    return normalizeGoalPlanShape(raw, payload);
  } catch (error) {
    console.error('[praxis-managed-ai] plan-goal fallback:', error);
    return mockPlanGoal(payload.goalText);
  }
}

async function handleReviewDay(payload) {
  if (!openAiApiKey) {
    return mockReviewDay(payload);
  }

  const request = {
    systemPrompt: [
      '你是 Praxis 的每日复盘助手。',
      '输出严格 JSON，不要 markdown，不要解释。',
      '只返回 summary 和 focus 两个字段。',
    ].join('\n'),
    userPayload: payload,
  };

  try {
    return apiProtocol === 'anthropic'
      ? await callAnthropicJson(request)
      : await callOpenAiJson(request);
  } catch (error) {
    console.error('[praxis-managed-ai] review-day fallback:', error);
    return mockReviewDay(payload);
  }
}

async function handleSuggestToday(payload) {
  if (!openAiApiKey) {
    return mockSuggestToday(payload);
  }

  const request = {
    systemPrompt: [
      '你是 Praxis 的今日建议助手。',
      '输出严格 JSON，不要 markdown，不要解释。',
      '只返回 suggestion 字段，内容控制在 20-40 个中文字符。',
    ].join('\n'),
    userPayload: payload,
  };

  try {
    return apiProtocol === 'anthropic'
      ? await callAnthropicJson(request)
      : await callOpenAiJson(request);
  } catch (error) {
    console.error('[praxis-managed-ai] suggest-today fallback:', error);
    return mockSuggestToday(payload);
  }
}

const server = createServer(async (request, response) => {
  if (request.method === 'OPTIONS') {
    json(response, 200, { ok: true });
    return;
  }

  if (request.url === '/health') {
    json(response, 200, {
      ok: true,
      managedAiConfigured: Boolean(openAiApiKey),
      provider: providerName,
      protocol: apiProtocol,
      baseUrl: openAiBaseUrl,
      model: openAiModel,
    });
    return;
  }

  if (!isAuthorized(request)) {
    unauthorized(response);
    return;
  }

  if (request.method !== 'POST') {
    if (
      request.url === '/plan-goal' ||
      request.url === '/review-day' ||
      request.url === '/suggest-today'
    ) {
      methodNotAllowed(response);
      return;
    }
    notFound(response);
    return;
  }

  try {
    const payload = await parseJsonBody(request);

    if (request.url === '/plan-goal') {
      json(response, 200, await handlePlanGoal(payload));
      return;
    }

    if (request.url === '/review-day') {
      json(response, 200, await handleReviewDay(payload));
      return;
    }

    if (request.url === '/suggest-today') {
      json(response, 200, await handleSuggestToday(payload));
      return;
    }

    notFound(response);
  } catch (error) {
    json(response, 500, {
      error: 'Internal server error',
      message: error instanceof Error ? error.message : String(error),
    });
  }
});

server.listen(port, () => {
  console.log(
    `[praxis-managed-ai] listening on http://0.0.0.0:${port} (managed=${Boolean(openAiApiKey)})`,
  );
});
