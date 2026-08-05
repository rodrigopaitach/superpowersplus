# The Process, Drawn

Every branch and back-edge of the interview: the investigation that gates the
first question, the coverage-map loop each answer re-enters, the visual
companion's two decision points, and the spec review's cap with its three
exits. `SKILL.md`'s Checklist names the same steps in the order they run —
what only this file shows is where each loop **returns to** and where the
review gate **breaks out**, which a numbered list cannot make visible at once.

Read it before your first question to the user.

```dot
digraph brainstorming {
    "Investigate code + deps\n(cite file:line / pinned source)" [shape=box];
    "Build coverage map\n(state + reason per category)" [shape=box];
    "Gap changes a decision?" [shape=diamond];
    "Preference against the\ncompanion declared?" [shape=diamond];
    "Question clearer shown\nthan described?" [shape=diamond];
    "Offer visual companion\n(its own message)" [shape=box];
    "Ask clarifying questions" [shape=box];
    "Propose 2-3 approaches" [shape=box];
    "Present design sections" [shape=box];
    "User approves design?" [shape=diamond];
    "Write design doc,\ncommit it" [shape=box];
    "Dispatch spec reviewer\nsubagent" [shape=box];
    "Reviewer approves?" [shape=diamond];
    "Round = 3, or a fixed\nblocker came back?" [shape=diamond];
    "Escalate the open blockers\n(escalation shape)" [shape=box];
    "Stop here: partner ends\nthe spec at this gap" [shape=doublecircle];
    "Present pending decisions\n(escalation shape, one message)" [shape=box];
    "User reviews spec?" [shape=diamond];
    "Invoke writing-plans skill" [shape=doublecircle];

    "Investigate code + deps\n(cite file:line / pinned source)" -> "Build coverage map\n(state + reason per category)";
    "Build coverage map\n(state + reason per category)" -> "Gap changes a decision?";
    "Gap changes a decision?" -> "Preference against the\ncompanion declared?" [label="yes, highest\nimpact x uncertainty first"];
    "Preference against the\ncompanion declared?" -> "Ask clarifying questions" [label="yes, text only\n(never say so)"];
    "Preference against the\ncompanion declared?" -> "Question clearer shown\nthan described?" [label="none declared,\nor favorable"];
    "Question clearer shown\nthan described?" -> "Offer visual companion\n(its own message)" [label="yes, and not\noffered yet"];
    "Question clearer shown\nthan described?" -> "Ask clarifying questions" [label="no"];
    "Offer visual companion\n(its own message)" -> "Ask clarifying questions";
    "Gap changes a decision?" -> "Propose 2-3 approaches" [label="no, record\nstate + reason"];
    "Ask clarifying questions" -> "Build coverage map\n(state + reason per category)" [label="integrate answer,\nsave spec"];
    "Propose 2-3 approaches" -> "Present design sections";
    "Present design sections" -> "User approves design?";
    "User approves design?" -> "Present design sections" [label="no, revise"];
    "User approves design?" -> "Write design doc,\ncommit it" [label="yes"];
    "Write design doc,\ncommit it" -> "Dispatch spec reviewer\nsubagent";
    "Dispatch spec reviewer\nsubagent" -> "Reviewer approves?";
    "Reviewer approves?" -> "Round = 3, or a fixed\nblocker came back?" [label="blocking issues"];
    "Round = 3, or a fixed\nblocker came back?" -> "Write design doc,\ncommit it" [label="no, fix and\nre-dispatch"];
    "Round = 3, or a fixed\nblocker came back?" -> "Escalate the open blockers\n(escalation shape)" [label="yes"];
    "Escalate the open blockers\n(escalation shape)" -> "Write design doc,\ncommit it" [label="rewrite the section"];
    "Escalate the open blockers\n(escalation shape)" -> "Present pending decisions\n(escalation shape, one message)" [label="accept, gap declared in\n## Assumptions to Confirm"];
    "Escalate the open blockers\n(escalation shape)" -> "Stop here: partner ends\nthe spec at this gap" [label="stop here"];
    "Reviewer approves?" -> "Present pending decisions\n(escalation shape, one message)" [label="yes"];
    "Present pending decisions\n(escalation shape, one message)" -> "User reviews spec?";
    "User reviews spec?" -> "Write design doc,\ncommit it" [label="changes requested"];
    "User reviews spec?" -> "Invoke writing-plans skill" [label="approved"];
}
```
