---
title: "Agents That Remember: Visual Memory for Personal AI"
authors: [xin-luna-dong]
categories: [LLMs, knowledge graphs, Data integration]
excerpt: "This post follows that arc: what the database community learned from the digital footprint, what we are building now that visual memory joins it, and what remains unsolved once the device records on its own."
image: /assets/posts/2026-11-17-agents-that-remember-visual-memory-for-personal-ai/figure1.png
---

It was during my PhD (2001-2007) that Personal Information Management drew attention from the database community. A person’s data, the files, emails, calendar entries, contacts and papers, is heterogeneous, scattered across applications, and governed by no schema anyone is willing to design upfront, which makes it a natural stress test for data integration. The problem never went away; it changed substrate. What was once a desktop of files is now a continuous record of what a person sees and hears, captured by glasses rather than typed into applications, and read by models that interpret a scene rather than a schema. This post follows that arc: what the database community learned from the digital footprint, what we are building now that visual memory joins it, and what remains unsolved once the device records on its own.

## The Past: Digital Footprint as Personal Information

Part of my PhD thesis is a Personal Information Management system called **Semex**, short for **Semantic Explorer** [1][2]. It automatically extracted real-world objects from everyday desktop data, such as people, publications and messages, together with the relationships among them, and presented the result as a personal information network rather than a hierarchy of files and folders. A user could then browse and query by relationship [3]: the papers written by people who had recently emailed them. Making this work hinged on reference reconciliation [4], deciding when “J. Smith” in a citation, an address in an inbox, and a contact-list entry denoted the same person. Crucially, none of it asked anything of the user: no tagging, no schema, no curation.

In hindsight the work pioneered two directions. First, personal information is essentially a knowledge graph, where nodes are entities and edges are the relationships between them. Knowledge graphs soon became a major research area, and the idea behind them, “things, not words”, changed how people search and view information on the web (e.g., Google and Bing Knowledge Panels). Even in the LLM era, they still remain the gold mine that grounds today’s RAG (Retrieval-Augmented Generation) systems.

Second, personal information management itself endured. The ETH group turned the abstraction into a running system with iMeMex, contributing a data model spanning files to tuples [5] and a way to add integration hints incrementally [6]. Interest then split. One line pushed on custody: as data moved to the cloud, the question became who holds it and under what guarantees, pursued by Inria from secure personal data servers on trusted hardware [7][8] to personal data management systems [9]. Another returned to representation, reviving the personal information network as the personal knowledge graph [10]. Most recently the LLM community reached the same problem from the other end, starting from the model rather than from the data. Generative Agents gave an agent a memory stream of past observations to retrieve from [11], MemGPT managed context as paged memory in the manner of an operating system [12], and a line of work from MemoryBank [13] to Mem0 [14] asks what an assistant should keep across sessions.

Running alongside all this, and for far longer, is the recommendation literature’s user profile. There the motivation was prediction, not organization: profiles existed to rank items, and the user was never meant to see them. The two threads have only recently converged. With LLMs the profile is textual and legible again: LaMP [15] made personalization a generation task, and MeKB-Rec [16] builds an explicit personal knowledge graph to carry preference across domains. What Semex called an association and what a recommender calls a feature are nearly the same object.

All of these, though, work from the *digital footprint*: the files, the posts, the shopping history, the cookie-tracked behavior. What about what people are seeing and hearing around them?

## The Present: Visual Memory into Personal Information

Visual memory is what the user sees and hears over time. The idea dates to 1945, when Vannevar Bush [17], in his vision of the Memex (MEMory & EXpansion), sketched a person with a camera bound to the forehead recording whatever came into view. That is only now becoming real, with GoPro cameras and smart glasses that people can wear to capture a photo or a recording whenever something is worth remembering, and multi-modal LLMs that let a machine interpret the physical world directly rather than only its digital traces.

<figure>
  <img src="{{ '/assets/posts/2026-11-17-agents-that-remember-visual-memory-for-personal-ai/figure1.png' | relative_url }}" alt="Left: the Memex sketch of a man with a camera strapped to his forehead. Right: a pair of Ray-Ban Meta smart glasses.">
  <figcaption><strong>Figure 1.</strong> <em>Memex sketch as in “As We May Think” [17], versus Ray-ban Meta smart glasses</em></figcaption>
</figure>

Despite the potential, capturing, constructing, and leveraging visual memory each faces real obstacles. *Capturing* is bound by the device: battery life and thermal headroom limit how long it can record, and storage and bandwidth limit how much it can keep. Beyond the hardware, the system must never record what it should not, and must protect privacy in capture, storage, and transmission.

*Construction* can largely happen offline, where compute is cheap and latency goes unobserved. The difficulty is noise, orders of magnitude more than in any digital footprint. Most of a recorded day is unremarkable, and much of what is kept is a poor guide to what the user likes: a photograph of a restaurant records that someone was there, not whether they enjoyed it. Separating what merely happened from what is genuinely preference-indicative has to come before anything downstream can work.

*Leveraging* the memory at runtime is harder still. Memory is dense, repetitive, and voluminous, while visual context windows are small and latency budgets are tight. Identifying which memories matter, staying robust to the noise that survived construction, and keeping up as preferences drift are all essential.

We next describe a few of our own efforts, which apply naturally to wearables such as smart glasses and more broadly to surfaces such as mobile apps, and close with the lessons we took from them.

### Pensieve and AssoMem: Recall QA on Past Memories

A natural starting point to support visual memory is to enable the user to photograph what is in view, optionally say what to remember, and ask about it later. This is formalized as **Memory-QA** [18], where a memory is a tuple of image, invocation command, timestamp, and location. **Pensieve**, the pipeline proposed there, addresses each challenge above. Offline it augments every snapshot with OCR text, a caption written with likely memory recall questions in mind, and a completion of the terse command, so “remember this” becomes “remember I parked at slot 142”. At query time a multi-signal retriever scores recency, date, and location alongside semantic similarity, and the generator is fine-tuned with injected noise to ignore irrelevant retrievals. It clearly outperforms state-of-the-art multimodal RAG, and, more tellingly, a text-only LLM over augmented memories matches a VLM (Visual Language Model) reading raw images.

As memory accumulates the problem changes character. A repository of thousands of entries becomes similarity-dense, the same recurring meeting, the same weekly shop, so that semantic distance no longer separates them. And many questions are not lookups but open-ended ones, such as “what do I usually complain about at work?”, answered by a pattern across many memories.

**AssoMem** [19] changes how memory is organized rather than how it is matched. It builds an associative memory graph, anchoring each utterance to extracted clues such as entities, events and topics, so the structure records what a memory is about and how often the user returns to it. Looser than a schematized personal knowledge graph, it supports an importance score from Personalized PageRank, surfacing memories central to a user’s history rather than merely nearest the query. Retrieval then fuses relevance, importance, and temporal alignment, weighted per question by mutual information. This yields consistent gains across three benchmarks and MeetingQA, a new dataset released with the paper. Two decades after Semex, association turned out to matter as much as similarity.

### VisualLens: Personalization with Visual Memory

Beyond recall, can we infer what a user cares about and use it for recommendation? **VisualLens** [20] takes that step. Its premise is that the photos a person takes are a task-agnostic record of their interests, a usable substitute for the interaction logs recommenders normally depend on. The difficulty is that everyday photos are noisy in a way click logs are not: the signal about someone’s taste in architecture sits in the same frame as a trash can. VisualLens associates each photo with a short list of aspect words, then refines them with an LLM so only terms that genuinely predict preference survive. At query time it retrieves the relevant images and grids them into a single composite, sidestepping the context-window limit. On two new benchmarks, Google-Review-V and Yelp-V, it outperforms both item-based multimodal recommenders and GPT-4o. The hard part, it turns out, is not seeing but judging: modern models describe a photo well, and the value lies in deciding which of the things it shows say something about the person who took it.

### MemLife and SaliMory: Handle Dense Memory with RL on Memory Writing

As memory grows denser, both QA and personalization get markedly harder. How does a person cope? A human takes in decades of unbroken sensory experience, far more than any wearable will record, and retains a vanishing fraction. Cognitive science has long held that we do not try to remember everything [23][24]: that is not a limitation working against lifelong recall, it is what makes lifelong recall possible. Human memory is selective by construction: a small working memory holds what is active now [25], while a long-term store keeps lived episodes apart from the facts and dispositions distilled from them [26]. What survives is a compressed trace, reconstructed on demand. A retrieval system’s instinct runs the other way: keep everything, and search harder. Inspired by human memory, can we build memory that is comprehensive in what it retains, yet selective in what it surfaces?

**MemLife** [21] targets memory QA over long-term egocentric video, where a history spans weeks or months and querying the raw stream is computationally intractable. Compressing video into text is the obvious remedy, but two bottlenecks compound: systems retrieve too little relevant evidence, and the memories they write are factually insufficient even when the right entries reach the reader. The second matters more, since no retrieval improvement recovers a fact the writer never recorded. MemLife therefore separates question-independent construction from query-time reasoning and concentrates on the former: offline, a writer turns each segment into a self-contained, first-person, entity-grounded narrative on a global timeline, so cost and storage grow linearly. Training that writer against feedback on whether its output is Faithfully grounded, Informative, and Retrievable (FIRM memory) improves accuracy on SuperMemory-VQA and generalizes to three other memory benchmarks.

**SaliMory** [22] targets personalization by giving memory a cognitive structure: a factual bank for verifiable statements, a preference bank for softer tastes that shape style rather than constrain content, and a working memory for what the user likely still has in mind. One model performs all three operations, filtering salient turns, consolidating them into the right store while retiring stale ones, and synthesizing a query-adapted profile at inference. Training this with reinforcement learning runs into credit assignment: when the answer is wrong, an outcome-only reward cannot say which stage failed. SaliMory resolves this with stage-wise process rewards and reward-decomposed contrastive refinement that routes gradients to the responsible role. Memory-attributed failures fall by a third, and the share of well-personalized responses more than doubles.

### Lessons Learned

Looking across these projects, three lessons stand out, and each will sound familiar to a database reader.

*Invest at write time.* In Pensieve, a text-only model over well-augmented memories matched a VLM reading the raw images; in MemLife, no retrieval improvement could recover a fact the writer never recorded. Again and again, the quality of an answer was decided long before the question was asked, at the moment the memory was written. This is the old lesson of materialized views: work done once, offline, pays off at every query.

*Loose structure beats none.* None of these systems imposes a schema, yet every one benefits from some structure: AssoMem’s clue graph, VisualLens’s aspect words, SaliMory’s separate stores for facts and preferences. The structure that helped was the one cheap enough to build automatically and expressive enough to rank by, which is pay-as-you-go integration by another name.

*Selectivity is a feature, not a loss.* The retrieval instinct is to keep everything and search harder. The larger gains came from deciding what not to keep or surface: dropping aspect words that do not predict preference, retiring stale memories, scoring importance rather than only similarity. Human memory had shown the way, and our systems improved as they learned to forget deliberately.

A more practical lesson runs underneath all three: most of these projects had to introduce a new benchmark, because the data that matters here, a person’s lived experience, is exactly what cannot be freely shared. Building realistic, privacy-respecting benchmarks for personal memory is itself a research problem the field has barely started on.

## The Future: Proactive Visual Memory Collection

In future we want the device to record proactively, according to what the user asks it to track, what might matter to them, or what is socially appropriate. Two visions follow. The first is a *second brain*, a store to which a person offloads thoughts and knowledge, supporting memory search, personalization, and eventually a memoir assembled from a life rather than reconstructed from it. The second is a *smart lens* offering information relevant to what the user is seeing, such as who designed the building in front of them, potentially proactively. The shift is from user-triggered data creation to automatic recording and automatic information recommendation, and every problem below follows from it.

### Proactive Memory Capture

Capture is where the hardware budget is spent, so its decisions are unforgiving. Always-on event detection must run continuously and judge, within a power envelope that admits no large model, whether a moment deserves a frame at all: whether it falls inside a space the user asked to track, carries incidental importance, or should be passed over as socially inappropriate. Duplicate detection must then suppress not merely redundant storage but redundant capture and transmission, since most of a day repeats the one before. Error either way is costly: too little and the memory has holes no model can fill; too much and the battery dies while the memory fills with noise.

### Proactive Service Offering

Proactive service inverts the retrieval problem. In reactive mode the question tells the system what to look for; proactive mode must judge from the surroundings alone whether to retrieve and what to retrieve. That is dense-memory search with no query to anchor it, a harder version of what AssoMem begins to address. Harder still is deciding to speak at all: not what to say but whether to say anything, and whether a guess at the user’s wishes is confident enough to act on without being presumptuous. The cost of error here is not a poor answer but an unwanted interruption, and too many of those and the feature is switched off.

### Evolving Personal Agent

Nothing about a user holds still. Tastes drift, opinions reverse, and the interest that dominated one season could vanish by the next. A memory that cannot let go of what was once true does not merely go stale; it starts recommending wrongly. Alongside this, every exchange teaches the agent how this particular user prefers to be served: how much detail they tolerate, when they want options instead of an answer, which subjects to leave alone, and which proactive offering is distractive rather than helpful. The agent tracks two moving targets, the person and its own model of them, and much of the difficulty lies in telling which one just moved.

### Protecting Personal Information

Finally, none of this is acceptable unless privacy is settled first, and it is the one area where a research result alone is insufficient. Capture must respect bystanders as well as the wearer, a social problem before it is a technical one. And memory needs a lifecycle: provenance for every entry, a path for the user to inspect, correct, and delete, and a guarantee that deletion propagates to everything derived from it. These guardrails run across all components rather than sitting at the end of the pipeline.

### Where Database Research Can Contribute Most

To leap towards the moonshot goals, I see the memory layer of a personal agent as where our data management community can contribute most. Today it is typically a vector index plus a handful of prompts; what it lacks is precisely what our community knows how to build. Four contributions seem most valuable and relevant here.

*A data model and query semantics for memory.* Episodes, facts, and preferences are different kinds of data with different update rules, and an agent needs to do lookups, aggregates (“what do I usually…”), and standing questions alike. Dataspaces argued two decades ago for pay-as-you-go structure over heterogeneous data [3][6]; memory is the same problem with a model as the writer, and it deserves the same rigor in defining what a query over it means and what an index over it should guarantee.

*Memory that is explicitly temporal.* An evolving agent must separate when something happened from when it learned it, and revise its beliefs without erasing history. Bitemporal modeling, versioning, and truth discovery over conflicting evidence [28] are mature tools for exactly this, and they are largely missing from today’s memory systems.

*Provenance and deletion that propagate.* The privacy lifecycle above, provenance for every entry and deletion that reaches everything derived from it, is data provenance [29] and deletion propagation through views [30] carried into a world where the views include summaries, profiles, and model weights. This is where database research is needed a lot, because it is the one guarantee users cannot verify for themselves.

*Capture and proactivity as query processing.* Deciding which moments to record under a power budget is close kin to acquisitional query processing in sensor networks, which pushed queries down to the device and chose what to sample [27]; deduplication at capture time is entity resolution on a stream under latency limits. Proactive service, likewise, is a standing query over the sensory stream, and deciding whether to speak is a trigger with a cost model, a question active databases asked long before agents did.

## Closing Thoughts

Twenty years ago, Semex asked how to make sense of a person’s digital data. The question has not changed; what has changed is that the data now arrives through a camera, the reader is a model, and soon the device will decide what to record. The database community laid much of the foundation, from integration and reference reconciliation to provenance and privacy, and I believe it has as much to offer this chapter as it did the first.

## References

1. Xin Luna Dong and Alon Halevy. *A Platform for Personal Information Management and Integration.* CIDR 2005.
2. Yuhan Cai, Xin Luna Dong, Alon Halevy, Jing Michelle Liu, and Jayant Madhavan. *Personal Information Management with Semex.* SIGMOD 2005 (demonstration).
3. Xin Luna Dong and Alon Halevy. *Indexing Dataspaces.* SIGMOD 2007.
4. Xin Luna Dong, Alon Halevy, and Jayant Madhavan. *Reference Reconciliation in Complex Information Spaces.* SIGMOD 2005.
5. Jens-Peter Dittrich and Marcos Antonio Vaz Salles. *iDM: A Unified and Versatile Data Model for Personal Dataspace Management.* VLDB 2006.
6. Marcos Antonio Vaz Salles, Jens-Peter Dittrich, Shant Kirakos Karakashian, Olivier René Girard, and Lukas Blunschi. *iTrails: Pay-as-you-go Information Integration in Dataspaces.* VLDB 2007.
7. Nicolas Anciaux, Luc Bouganim, Philippe Pucheral, et al. *Secure Personal Data Servers: a Vision Paper.* VLDB 2010.
8. Nicolas Anciaux, Luc Bouganim, Philippe Pucheral, et al. *Pluggable Personal Data Servers.* SIGMOD 2010 (demonstration).
9. Nicolas Anciaux, Luc Bouganim, Philippe Pucheral, et al. *Personal Data Management Systems: The Security and Functionality Standpoint.* VLDB 2019 (tutorial).
10. Krisztian Balog and Tom Kenter. *Personal Knowledge Graphs: A Research Agenda.* ICTIR 2019.
11. Joon Sung Park, Joseph C. O’Brien, Carrie J. Cai, Meredith Ringel Morris, Percy Liang, and Michael S. Bernstein. *Generative Agents: Interactive Simulacra of Human Behavior.* UIST 2023. arXiv:2304.03442.
12. Charles Packer, Sarah Wooders, Kevin Lin, Vivian Fang, Shishir G. Patil, Ion Stoica, and Joseph E. Gonzalez. *MemGPT: Towards LLMs as Operating Systems.* 2023. arXiv:2310.08560.
13. Wanjun Zhong, Lianghong Guo, Qiqi Gao, He Ye, and Yanlin Wang. *MemoryBank: Enhancing Large Language Models with Long-Term Memory.* 2023. arXiv:2305.10250.
14. Prateek Chhikara, Dev Khant, Saket Aryan, Taranjeet Singh, and Deshraj Yadav. *Mem0: Building Production-Ready AI Agents with Scalable Long-Term Memory.* 2025. arXiv:2504.19413.
15. Alireza Salemi, Sheshera Mysore, Michael Bendersky, and Hamed Zamani. *LaMP: When Large Language Models Meet Personalization.* 2023. arXiv:2304.11406.
16. Xin Su, Yao Zhou, Zifei Shan, and Qian Chen. *MeKB-Rec: Personal Knowledge Graph Learning for Cross-Domain Recommendation.* 2023. arXiv:2310.11088.
17. Vannevar Bush. *As We May Think.* The Atlantic Monthly, July 1945.
18. Hongda Jiang, Xinyuan Zhang, Siddhant Garg, Rishab Arora, Shiun-Zu Kuo, Jiayang Xu, Ankur Bansal, Aaron Colak, Yue Liu, Ahmed Aly, Anuj Kumar, and Xin Luna Dong. *Memory-QA: Answering Recall Questions Based on Multimodal Memories.* EMNLP 2025. arXiv:2509.18436.
19. Kai Zhang, Xinyuan Zhang, Ejaz Ahmed, Hongda Jiang, Caleb Kumar, Kai Sun, Zhaojiang Lin, Sanat Sharma, Shereen Oraby, Aaron Colak, Ahmed A. Aly, Anuj Kumar, Xiaozhong Liu, and Xin Luna Dong. *AssoMem: Scalable Memory QA with Multi-Signal Associative Retrieval.* NeurIPS 2025. arXiv:2510.10397.
20. Wang Bill Zhu, Deqing Fu, Kai Sun, Yi Lu, Zhaojiang Lin, Seungwhan Moon, Kanika Narang, Mustafa Canim, Yue Liu, Anuj Kumar, and Xin Luna Dong. *VisualLens: Personalization through Visual History.* NeurIPS 2025. arXiv:2411.16034.
21. Guangzhi Xiong, Xinyuan Zhang, Xiao Yang, Hyokun Yun, Kai Zhang, Shiun-Zu Kuo, Hyeonjeong Ha, Xilun Chen, Kai Sun, Lucas Liang, Guangqiang Dong, Ejaz Ahmed, Ahmed A Aly, Anuj Kumar, Raffay Hamid, Aidong Zhang, Xin Luna Dong. *MemLife: Remembering and Reasoning over Long-Term Egocentric Videos.* arXiv, 2027.
22. Kai Zhang, Xinyuan Zhang, Hongda Jiang, Shiun-Zu Kuo, Hyokun Yun, Ejaz Ahmed, Shereen Oraby, Ziyun Li, Sanat Sharma, Ann Lee, Ahmed A. Aly, Anuj Kumar, Raffay Hamid, and Xin Luna Dong. *SaliMory: Orchestrating Cognitive Memory for Conversational Agents.* 2026. arXiv:2606.04120.
23. R. C. Atkinson and R. M. Shiffrin. *Human Memory: A Proposed System and Its Control Processes.* Psychology of Learning and Motivation 2, pp. 89–195, 1968.
24. A. Baddeley. *The Episodic Buffer: A New Component of Working Memory?* Trends in Cognitive Sciences 4(11), pp. 417–423, 2000.
25. A. D. Baddeley and G. Hitch. *Working Memory.* In The Psychology of Learning and Motivation: Advances in Research and Theory, G. H. Bower (Ed.), Vol. 8, pp. 47–89, 1974.
26. E. Tulving. *Episodic and Semantic Memory.* Organization of Memory, pp. 381–403, 1972.
27. Samuel R. Madden, Michael J. Franklin, Joseph M. Hellerstein, and Wei Hong. *TinyDB: An Acquisitional Query Processing System for Sensor Networks.* ACM TODS 30(1), 2005.
28. Xin Luna Dong, Laure Berti-Equille, and Divesh Srivastava. *Integrating Conflicting Data: The Role of Source Dependence.* VLDB 2009.
29. Todd J. Green, Grigoris Karvounarakis, and Val Tannen. *Provenance Semirings.* PODS 2007.
30. Peter Buneman, Sanjeev Khanna, and Wang-Chiew Tan. *On Propagation of Deletions and Annotations through Views.* PODS 2002.

## About the Author

*Xin Luna Dong is a Principal Scientist at Meta Wearables AI, where she leads the Agentic AI efforts for building trustworthy and personalized assistants on wearable devices. Previously, she spent over a decade advancing knowledge graph technology, including the Amazon Product Graph and the Google Knowledge Graph. She is co-author of Machine Knowledge: Creation and Curation of Comprehensive Knowledge Bases and Big Data Integration.*

*She was named an ACM Fellow and an IEEE Fellow for "significant contributions to knowledge graph construction and data integration," and has received the VLDB Women in Database Research Award, the VLDB Early Career Research Contribution Award, and recently the SigKDD 2026 Best Paper Award (Data & Benchmark track). She has also served as an ACM Distinguished Speaker, a member of the VLDB Endowment, and PC co-chair for ICDM'27, SigKDD'22 (ADS track), WSDM'22, VLDB'21, and SIGMOD'18.*
