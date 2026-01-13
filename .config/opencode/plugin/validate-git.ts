import type { Plugin } from "@opencode-ai/plugin";

const getToday = (): string => new Date().toISOString().split("T")[0];

const rules = {
  squashRebaseMerge: (cmd: string): void => {
    if (/gh pr merge.*(--squash|--rebase)/.test(cmd)) {
      throw new Error(
        "❌ Regular merge only. squash/rebase 금지.\n   사용: gh pr merge (옵션 없이)",
      );
    }
  },

  branchControl: (cmd: string): void => {
    // checkout -b, switch -c 차단
    if (/git (checkout -b|switch -c)/.test(cmd)) {
      throw new Error(
        "❌ 직접 브랜치 생성 금지.\n   사용: gh issue develop {issue} --checkout --name {issue}/{worker}/{YYYY-MM-DD}",
      );
    }

    // git branch 조작 차단 (읽기만 허용: 인자 없음, -a, -r, -v, --list)
    if (/git branch(?!\s*$|\s+(-a|-r|-v|--list))/.test(cmd)) {
      throw new Error(
        "❌ git branch 조작 금지. 브랜치 생성은 gh issue develop 사용.",
      );
    }
  },

  commitMessageFormat: (cmd: string): void => {
    if (!/git commit/.test(cmd)) return;

    const msgMatch = cmd.match(/git commit.*-m\s+["'](.+?)["']/);
    if (!msgMatch) return;

    const msg = msgMatch[1];

    if (!/^(feat|fix|docs|chore): .+/.test(msg)) {
      throw new Error(
        `❌ 커밋 메시지 형식 오류.\n   형식: {type}: {한글 메시지}\n   type: feat, fix, docs, chore\n   현재: "${msg}"`,
      );
    }

    if (!/[가-힣]/.test(msg)) {
      throw new Error(
        `❌ 커밋 메시지에 한글이 필요합니다.\n   형식: {type}: {한글 메시지}\n   현재: "${msg}"`,
      );
    }
  },

  branchNameFormat: (cmd: string): void => {
    if (!/gh issue develop/.test(cmd)) return;

    const nameMatch = cmd.match(/--name[= ]+["']?([^"'\s]+)["']?/);
    if (!nameMatch) {
      throw new Error(
        "❌ --name 옵션 필수.\n   사용: gh issue develop {issue} --checkout --name {issue}/{worker}/{YYYY-MM-DD}",
      );
    }

    const branchName = nameMatch[1];
    if (!/^\d+\/[a-zA-Z0-9_-]+\/\d{4}-\d{2}-\d{2}$/.test(branchName)) {
      throw new Error(
        `❌ 브랜치 이름 형식 오류.\n   형식: {issue}/{worker}/{YYYY-MM-DD}\n   예시: 123/ensia96/${getToday()}\n   현재: "${branchName}"`,
      );
    }
  },

  prTitleFormat: (cmd: string): void => {
    if (!/gh pr create/.test(cmd)) return;

    const titleMatch = cmd.match(/--title[= ]+["'](.+?)["']/);
    if (!titleMatch) return;

    const title = titleMatch[1];
    if (!/^\[#\d+\] [a-zA-Z0-9_-]+ \(\d{4}-\d{2}-\d{2}\)$/.test(title)) {
      throw new Error(
        `❌ PR 제목 형식 오류.\n   형식: [#{issue}] {worker} ({YYYY-MM-DD})\n   예시: [#123] ensia96 (${getToday()})\n   현재: "${title}"`,
      );
    }
  },
};

const validateCommand = (cmd: string): void => {
  rules.squashRebaseMerge(cmd);
  rules.branchControl(cmd);
  rules.commitMessageFormat(cmd);
  rules.branchNameFormat(cmd);
  rules.prTitleFormat(cmd);
};

export const ValidateGit: Plugin = async (_ctx) => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "bash" && input.tool !== "mcp_bash") return;

      const cmd = output.args?.command;
      if (!cmd || typeof cmd !== "string") return;

      validateCommand(cmd);
    },
  };
};
