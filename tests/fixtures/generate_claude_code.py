"""Generates hand-written, fully synthetic Claude Code fixtures for Wake tests."""
import json, os, sys

OUT = sys.argv[1]  # .../tests/fixtures/claude-code/projects
VER = "2.1.292"

def sid(n): return "00000000-0000-4000-8000-%012d" % n
def uid(s, n): return "%08d-1111-4000-8000-%012d" % (s, n)

class Session:
    def __init__(self, n, cwd, branch="main", start="2026-09-01T10:00:00.000Z", sidechain=False, agent_id=None, session_id=None):
        self.id = session_id or sid(n); self.n = n; self.cwd = cwd; self.branch = branch
        self.lines = []; self.k = 0; self.last = None; self.sidechain = sidechain; self.agent_id = agent_id
    def env(self, typ, ts, **kw):
        self.k += 1
        u = uid(self.n * 10 + (1 if self.sidechain else 0), self.k)
        r = {"parentUuid": self.last, "isSidechain": self.sidechain}
        if self.agent_id: r["agentId"] = self.agent_id
        r.update({"type": typ}); r.update(kw)
        r.update({"uuid": u, "timestamp": ts, "userType": "external", "entrypoint": "cli",
                  "cwd": self.cwd, "sessionId": self.id, "version": VER, "gitBranch": self.branch})
        self.last = u; self.lines.append(json.dumps(r)); return u
    def meta(self, **kw):
        r = dict(kw); r["sessionId"] = self.id; self.lines.append(json.dumps(r))
    def raw(self, s): self.lines.append(s)
    def user(self, ts, content, **kw):
        return self.env("user", ts, message={"role": "user", "content": content}, **kw)
    def assistant(self, ts, msg_id, block, usage, model="claude-opus-5-5", stop="tool_use", **kw):
        return self.env("assistant", ts, message={"model": model, "id": msg_id, "type": "message", "role": "assistant",
                        "content": [block], "stop_reason": stop, "stop_sequence": None, "usage": usage},
                        requestId="req_" + msg_id[4:], **kw)
    def result(self, ts, tool_id, content, tur, src, is_error=None):
        block = {"tool_use_id": tool_id, "type": "tool_result", "content": content}
        if is_error is not None: block["is_error"] = is_error
        return self.user(ts, [block], toolUseResult=tur, sourceToolAssistantUUID=src)
    def write(self, folder, name=None, trailing=""):
        os.makedirs(folder, exist_ok=True)
        with open(os.path.join(folder, (name or self.id) + ".jsonl"), "w") as f:
            f.write("\n".join(self.lines) + "\n" + trailing)

def usage(i, o, cw=0, cr=0):
    return {"input_tokens": i, "cache_creation_input_tokens": cw, "cache_read_input_tokens": cr, "output_tokens": o,
            "server_tool_use": {"web_search_requests": 0, "web_fetch_requests": 0}, "service_tier": "standard",
            "cache_creation": {"ephemeral_1h_input_tokens": cw, "ephemeral_5m_input_tokens": 0}}

DEMO = "/Users/dev/demo"
DEMO_DIR = os.path.join(OUT, "-Users-dev-demo")

# 1. Basic prompt and answer, response split across two records with repeated usage.
s = Session(1, DEMO)
s.meta(type="permission-mode", permissionMode="default")
s.user("2026-09-01T10:00:00.000Z", "Explain what the parse function in main.c does.", promptId="p-1")
u1 = usage(100, 50, 1000, 2000)
s.assistant("2026-09-01T10:00:02.000Z", "msg_basic_01", {"type": "thinking", "thinking": "", "signature": "c2lnbmF0dXJl"}, u1)
s.assistant("2026-09-01T10:00:03.000Z", "msg_basic_01", {"type": "text", "text": "It reads one line at a time and splits it on commas."}, u1, stop="end_turn")
s.env("system", "2026-09-01T10:00:03.500Z", subtype="turn_duration", durationMs=3500, messageCount=3, isMeta=False)
s.meta(type="ai-title", aiTitle="Explain parse function")
s.meta(type="last-prompt", lastPrompt="Explain what the parse function in main.c does.", leafUuid=s.last)
s.write(DEMO_DIR)

# 2. Tools: Bash, Edit, Write (create), parallel Reads, an error result, persisted output.
s = Session(2, DEMO, branch="feature/csv")
s.user("2026-09-02T09:00:00.000Z", "Fix the failing CSV test.", promptId="p-2")
ua = usage(10, 20, 500, 1000)
s.assistant("2026-09-02T09:00:01.000Z", "msg_tools_01", {"type": "text", "text": "Let me run the tests first."}, ua)
a = s.assistant("2026-09-02T09:00:01.500Z", "msg_tools_01", {"type": "tool_use", "id": "toolu_bash_01", "name": "Bash",
    "input": {"command": "make test", "description": "Run tests"}}, ua)
s.result("2026-09-02T09:00:04.000Z", "toolu_bash_01", "FAIL test_csv: expected 3 fields, got 2\nExit code 1",
    {"stdout": "FAIL test_csv: expected 3 fields, got 2", "stderr": "", "interrupted": False, "isImage": False, "noOutputExpected": False},
    a, is_error=True)
ub = usage(5, 30, 200, 1500)
a1 = s.assistant("2026-09-02T09:00:05.000Z", "msg_tools_02", {"type": "tool_use", "id": "toolu_read_01", "name": "Read",
    "input": {"file_path": "/Users/dev/demo/main.c"}}, ub)
a2 = s.assistant("2026-09-02T09:00:05.100Z", "msg_tools_02", {"type": "tool_use", "id": "toolu_read_02", "name": "Read",
    "input": {"file_path": "/Users/dev/demo/test.c"}}, ub)
# Results arrive in reverse order: pair by id, not position.
s.result("2026-09-02T09:00:05.300Z", "toolu_read_02", "1\t#include \"csv.h\"\n2\tint main(void) { return run(); }",
    {"type": "text", "file": {"filePath": "/Users/dev/demo/test.c", "content": "#include \"csv.h\"\nint main(void) { return run(); }", "numLines": 2, "startLine": 1, "totalLines": 2}}, a2)
s.result("2026-09-02T09:00:05.200Z", "toolu_read_01", "1\tint parse(char *s) {\n2\t  return split(s, ',');\n3\t}",
    {"type": "text", "file": {"filePath": "/Users/dev/demo/main.c", "content": "int parse(char *s) {\n  return split(s, ',');\n}", "numLines": 3, "startLine": 1, "totalLines": 3}}, a1)
s.env("attachment", "2026-09-02T09:00:05.150Z", attachment={"type": "todo_reminder", "content": [], "itemCount": 0})
uc = usage(3, 40, 0, 3000)
a = s.assistant("2026-09-02T09:00:08.000Z", "msg_tools_03", {"type": "tool_use", "id": "toolu_edit_01", "name": "Edit",
    "input": {"file_path": "/Users/dev/demo/main.c", "old_string": "  return split(s, ',');", "new_string": "  return split_quoted(s, ',');", "replace_all": False}}, uc)
s.result("2026-09-02T09:00:08.200Z", "toolu_edit_01", "The file /Users/dev/demo/main.c has been updated successfully.",
    {"filePath": "/Users/dev/demo/main.c", "oldString": "  return split(s, ',');", "newString": "  return split_quoted(s, ',');",
     "originalFile": "int parse(char *s) {\n  return split(s, ',');\n}", "replaceAll": False, "userModified": False,
     "structuredPatch": [{"oldStart": 1, "oldLines": 3, "newStart": 1, "newLines": 3,
                          "lines": [" int parse(char *s) {", "-  return split(s, ',');", "+  return split_quoted(s, ',');", " }"]}]}, a)
ud = usage(2, 60, 0, 3500)
a = s.assistant("2026-09-02T09:00:10.000Z", "msg_tools_04", {"type": "tool_use", "id": "toolu_write_01", "name": "Write",
    "input": {"file_path": "/Users/dev/demo/NOTES.md", "content": "# Notes\n\nQuoted fields are now supported.\n"}}, ud)
s.result("2026-09-02T09:00:10.100Z", "toolu_write_01", "File created successfully at: /Users/dev/demo/NOTES.md",
    {"type": "create", "filePath": "/Users/dev/demo/NOTES.md", "content": "# Notes\n\nQuoted fields are now supported.\n",
     "structuredPatch": [], "originalFile": None, "userModified": False}, a)
ue = usage(1, 15, 0, 4000)
a = s.assistant("2026-09-02T09:00:12.000Z", "msg_tools_05", {"type": "tool_use", "id": "toolu_bash_02", "name": "Bash",
    "input": {"command": "make test VERBOSE=1", "description": "Run tests verbosely"}}, ue)
s.result("2026-09-02T09:00:20.000Z", "toolu_bash_02",
    "<persisted-output>\nOutput too large (2KB). Full output saved to: /Users/dev/.claude/projects/-Users-dev-demo/" + s.id + "/tool-results/bfixture01.txt\n</persisted-output>",
    {"stdout": "", "stderr": "", "interrupted": False, "isImage": False, "noOutputExpected": False,
     "persistedOutputPath": "/Users/dev/.claude/projects/-Users-dev-demo/" + s.id + "/tool-results/bfixture01.txt", "persistedOutputSize": 2048}, a)
uf = usage(1, 25, 0, 4500)
s.assistant("2026-09-02T09:00:21.000Z", "msg_tools_06", {"type": "text", "text": "All tests pass now. I changed parse to use split_quoted."}, uf, stop="end_turn")
s.meta(type="ai-title", aiTitle="Fix CSV test")
s.meta(type="ai-title", aiTitle="Fix failing CSV quoting test")
s.meta(type="cost-state", totalCostUSD=0.1234, totalAPIDuration=9000, totalAPIDurationWithoutRetries=9000, totalToolDuration=11000,
       totalLinesAdded=4, totalLinesRemoved=1, totalDuration=21000, startTime=1788339600000,
       modelUsage={"claude-opus-5-5": {"inputTokens": 22, "outputTokens": 190, "thinkingTokens": 0, "cacheReadInputTokens": 17500,
                   "cacheCreationInputTokens": 700, "webSearchRequests": 0, "costUSD": 0.1234}}, hasUnknownModelCost=False)
s.write(DEMO_DIR)
tr = os.path.join(DEMO_DIR, s.id, "tool-results"); os.makedirs(tr, exist_ok=True)
with open(os.path.join(tr, "bfixture01.txt"), "w") as f:
    f.write("".join("ok %d - test_case_%d\n" % (i, i) for i in range(1, 121)))

# 3. Robustness: unknown record and block types, unknown fields, malformed line, meta prompts, synthetic error, truncated tail.
s = Session(3, DEMO)
s.user("2026-09-03T08:00:00.000Z", "<command-name>/clear</command-name>\n<command-message>clear</command-message>\n<command-args></command-args>")
s.user("2026-09-03T08:00:00.100Z", "Caveat: the messages below were generated by the user while running local commands.", isMeta=True)
s.env("attachment", "2026-09-03T08:00:00.200Z", attachment={"type": "date", "date": "2026-09-03"})
s.user("2026-09-03T08:00:01.000Z", [{"type": "text", "text": "What does this screenshot show?"},
                                   {"type": "image", "source": {"type": "base64", "media_type": "image/png", "data": "iVBORw0KGgo="}}], promptId="p-3")
s.raw('{"type":"assistant","message":{"content":[{"type":"text","text":"this line is cut')
s.meta(type="future-record-kind", payload={"anything": True})
ug = usage(10, 10, 0, 0)
s.assistant("2026-09-03T08:00:02.000Z", "msg_rob_01", {"type": "hologram", "data": "unknown block kind"}, ug, someNewField={"x": 1})
s.assistant("2026-09-03T08:00:02.500Z", "msg_rob_01", {"type": "text", "text": "It shows a terminal with a failing build."}, ug, stop="end_turn")
s.raw("")
s.raw("not json at all")
s.assistant("2026-09-03T08:00:03.000Z", "msg_synthetic_01", {"type": "text", "text": "API Error: 529 Overloaded"},
    usage(0, 0), model="<synthetic>", stop="stop_sequence", isApiErrorMessage=True)
s.env("system", "2026-09-03T08:00:04.000Z", subtype="informational", content="Context limit nearly reached", level="warning", isMeta=False)
s.user("2026-09-03T08:00:05.000Z", "<task-notification>\n<task-id>bg1</task-id>\n<status>completed</status>\n</task-notification>")
s.write(DEMO_DIR, trailing='{"parentUuid":"x","type":"user","message":{"role":"user","con')

# 4. Subagent: parent with an Agent call, and a subagent transcript plus meta.json.
s = Session(4, DEMO)
s.user("2026-09-04T12:00:00.000Z", "Find every TODO in the repo.", promptId="p-4")
uh = usage(20, 30, 100, 100)
a = s.assistant("2026-09-04T12:00:01.000Z", "msg_sub_01", {"type": "tool_use", "id": "toolu_agent_01", "name": "Agent",
    "input": {"description": "Find TODOs", "prompt": "List every TODO comment.", "subagent_type": "Explore"}}, uh)
s.result("2026-09-04T12:00:30.000Z", "toolu_agent_01", [{"type": "text", "text": "Found 2 TODOs: main.c:10, test.c:4"}],
    {"status": "completed", "agentId": "a0fixture000001", "description": "Find TODOs", "prompt": "List every TODO comment.",
     "resolvedModel": "claude-haiku-4-5-20251001", "isAsync": False}, a)
s.assistant("2026-09-04T12:00:31.000Z", "msg_sub_02", {"type": "text", "text": "There are two TODOs: main.c line 10 and test.c line 4."}, usage(5, 20, 0, 300), stop="end_turn")
s.meta(type="ai-title", aiTitle="Find TODOs")
s.write(DEMO_DIR)
sub = Session(4, DEMO, sidechain=True, agent_id="a0fixture000001", session_id=s.id)
sub.user("2026-09-04T12:00:01.500Z", "List every TODO comment.", promptId="p-4s")
ui = usage(50, 10, 0, 0)
a = sub.assistant("2026-09-04T12:00:02.000Z", "msg_sub_a1", {"type": "tool_use", "id": "toolu_grep_01", "name": "Grep",
    "input": {"pattern": "TODO", "path": "/Users/dev/demo"}}, ui, model="claude-haiku-4-5-20251001")
sub.result("2026-09-04T12:00:03.000Z", "toolu_grep_01", "main.c:10: // TODO handle escapes\ntest.c:4: // TODO more cases",
    {"mode": "content", "numFiles": 2, "filenames": [], "content": "main.c:10: // TODO handle escapes\ntest.c:4: // TODO more cases", "numLines": 2}, a)
sub.assistant("2026-09-04T12:00:04.000Z", "msg_sub_a2", {"type": "text", "text": "Found 2 TODOs: main.c:10, test.c:4"}, usage(60, 15, 0, 0),
    model="claude-haiku-4-5-20251001", stop="end_turn")
subdir = os.path.join(DEMO_DIR, s.id, "subagents")
sub.write(subdir, "agent-a0fixture000001")
with open(os.path.join(subdir, "agent-a0fixture000001.meta.json"), "w") as f:
    json.dump({"agentType": "Explore", "description": "Find TODOs", "toolUseId": "toolu_agent_01", "spawnDepth": 1,
               "requestShape": "standard", "requestNonInteractive": True}, f)

# 5. Empty file.
open(os.path.join(DEMO_DIR, sid(5) + ".jsonl"), "w").close()

# 6. Project with spaces and dots in its path: folder name can't be decoded.
cwd = "/Users/dev/Open Source/demo.app"
s = Session(6, cwd, branch="")
s.user("2026-09-05T18:30:00.000Z", "Hello", promptId="p-6")
s.assistant("2026-09-05T18:30:01.000Z", "msg_space_01", {"type": "text", "text": "Hi! How can I help?"}, usage(7, 9), stop="end_turn")
s.write(os.path.join(OUT, "-Users-dev-Open-Source-demo-app"))

# Not a session: memory notes are ignored.
mem = os.path.join(DEMO_DIR, "memory"); os.makedirs(mem, exist_ok=True)
with open(os.path.join(mem, "MEMORY.md"), "w") as f: f.write("- [Example](example.md) - not a transcript\n")
