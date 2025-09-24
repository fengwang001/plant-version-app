## 植物识别与 AI 视频 UGC 应用（iOS/Android）V1 详细计划（Scope）

> 本文为实施级计划，覆盖范围与约束、KPI、功能清单、架构与数据、API 纲要、AI 与支付选型、配额与计费细则、UI/UX、运维、里程碑、验收标准与风险缓解。原型以 `zh-02.html` 为准（`file:///C:/workspace/Plant/20250916/zh-02.html`）。本阶段仅规划，不落地开发代码。

## 1. 范围与约束
- 平台：仅 iOS 与 Android（Flutter 构建）。
- 第三方优先：植物识别与视频生成优先对接第三方 API，由智能体 Agent 编排。
- 订阅与配额：月订阅 $20，月配额 200 次；新用户首月含 5 次免费；可购买超额包（Consumable）。
- 知识内容：开放数据 + AI 总结 + 标注来源；作者可编辑；浏览者可评论。
- 支付与合规：移动端数字内容走 Apple IAP / Google Play Billing；推荐 RevenueCat 聚合管理；（预留未来多端用 Stripe）。
- 审核：默认关闭，预留服务端与客户端开关，可随时启用。
- 云与合规：无指定云厂商；资源与数据落美国区域（US）。
- UI：PlantVision 清新风格，绿色/紫色品牌色彩，圆角卡片设计（Material 3）。

## 2. 成功指标（KPI）
- 识别准确率：Top-1 ≥ 80%，Top-3 ≥ 95%（以 Plant.id/Pl@ntNet 实测为准）。
- 视频生成完成率：T90 ≤ 10 分钟，完成率 ≥ 95%。
- 付费：免费用尽后订阅转化 ≥ 5%；月留存 ≥ 60%。
- UGC：DAU 中 ≥ 2% 产生作品；互动率（点/藏/评）≥ 15%。

## 3. 用户旅程与关键流
1) 新用户 → 授权相机/相册 → 上传图片 → 识别成功 → 展示百科与季节/地区差异 → 引导生成视频（显示剩余额度）→ 完成 → 发布作品。
2) 免费用尽 → 付费墙（月 200 + 超额包）→ 订阅成功 → 继续生成；失败回退提示与恢复购买。
3) 浏览作品流 → 点赞/收藏/评论 → 关注作者 → 回访留存。

## 4. 功能范围（V1）
- 识别与百科
  - 拍照/相册上传，Top-K 候选（学名/俗名/置信度）。
  - 百科详情（形态、习性、养护、毒性、常见病害），引用与来源标注。
  - 季节/地区差异：月份、气候带/地区维度下的形态与示例图。
- AI 视频生成
  - 生成参数：风格（真实/插画/唯美/微距）、时长（5/10/15s）、提示词、音乐选择。
  - 异步队列、进度展示、完成通知（本地/推送占位）。
  - 配额：首月 5 次免费、月配额 200、超额包可购。
- 作品与社区
  - 发布图文/视频作品，话题/标签。
  - 作品流（瀑布/短视频）、详情页（赞/藏/评/浏览量）。
  - 个人主页：作品、订阅状态、识别历史。
- 支付与订阅
  - IAP 订阅（$20/月，自动续费）与 Consumable 超额包（如 20 次/50 次）。
  - 恢复购买、票据校验、状态同步、失败回退。
- 系统与设置
  - 登录（Apple/Google/邮箱）、通知、隐私、数据下载/注销。
  - 暗色主题、基础多语言（中/英，默认英文，落美区）。

## 5. 架构选型（US 区）
- 客户端（Flutter）
  - 状态：GetX；网络：Dio（可配合 Retrofit）；序列化：json_serializable + freezed。
  - 缓存：Hive；权限：permission_handler；媒体：camera/image_picker/cached_network_image。
  - 主题：Material 3 暗色；导航：GetX 路由；通知：FCM（预留）。
- 服务端（Python）
  - API：FastAPI；鉴权：JWT；ORM：SQLAlchemy；迁移：Alembic。
  - 异步：Celery + Redis；存储：PostgreSQL；对象存储：S3 兼容 + CDN。
  - 智能体：LangGraph/LangChain（Orchestrator/子 Agent）、可观测事件落库。
  - 监控：Prometheus + Grafana；日志：ELK/Cloud Logging；崩溃：Sentry。
- 第三方
  - 植物识别：Plant.id（主），Pl@ntNet（备）。
  - 视频生成：Replicate（主起步），Pika（小流量 A/B），Runway（高质量模板）。
  - 支付：Apple IAP / Google Play Billing（必选），RevenueCat（推荐聚合），Stripe（预留多端）。

## 6. 智能体（Agent）编排
- Orchestrator Agent：路由与状态机（识别 → 知识补全 → 季节/地区查询 → 提示词生成 → 视频生成 → 通知）。
- Identification Agent：调用 Plant.id/Pl@ntNet，合并 Top-K，低置信度触发重试/备选切换。
- Knowledge Agent：聚合开放数据 + 内部库，AI 总结并输出来源与置信度；作者编辑留痕。
- Prompt Engineer Agent：依据植物特征/季节/地区与用户意图生成专业视频提示词与参数。
- Video Agent：按质量/排队/成本选择供应商，异步轮询，失败退避与回落。
- Moderation Agent：默认关闭，开关启用后执行图像/文本/视频审核与拦截。

## 7. 数据模型（核心表）
- 账户与计费：`users`, `subscriptions`, `payments`, `iap_receipts`, `credits`
- 植物与知识：`plants`, `plant_aliases`, `plant_media`, `plant_seasonality`, `regions`, `sources`
- 识别与生成：`observations`, `media_assets`, `video_jobs`, `video_presets`, `job_events`
- 社区与互动：`posts`, `post_media`, `likes`, `favorites`, `comments`, `views`, `reports`
- 风控与通知：`devices`, `abuse_flags`, `audit_logs`, `notifications`, `events_analytics`
- 关键约束
  - `credits` 维护 feature=video_generation 的月配额、已用量、免费额度；服务端权威扣减。
  - `video_jobs` 记录 provider、成本、状态、失败原因与回调；便于成本核算与复盘。
  - `sources` 统一管理开放数据来源与可信度，知识字段存来源 ID 与更新时间。

## 8. API 纲要（FastAPI）
- Auth：`POST /auth/login`, `POST /auth/refresh`, `POST /auth/logout`
- 媒体：`POST /media/presign`, `POST /media/confirm`
- 植物：`POST /plants/identify`, `GET /plants/{id}`, `GET /plants/{id}/seasonality?region=...`
- 知识编辑与评论：`POST /plants/{id}/edit`（作者）、`GET/POST /plants/{id}/comments`
- 视频：`POST /videos`（创建任务）、`GET /videos/{jobId}`（查询）、`POST /webhooks/video`
- 作品与互动：`GET/POST /posts`, `GET /posts/{id}`, `POST /posts/{id}/like`, `POST /posts/{id}/favorite`, `POST /posts/{id}/comment`, `POST /posts/{id}/view`
- 订阅与配额：`POST /iap/validate`, `GET /subscriptions/me`, `GET /credits/me`, `POST /credits/consume`
- Webhook：`POST /webhooks/iap`, `POST /webhooks/revenuecat`

## 9. 支付处理三选项与结论
1) Apple IAP / Google Play Billing（必选）
   - 优点：平台合规、体验流畅、结算稳定、风控成熟。
   - 缺点：多平台对账复杂、税率与分成固定、票据校验实现繁琐。
   - 适用：App 内数字内容订阅与超额包（Consumable）。
2) RevenueCat（强烈推荐）
   - 优点：统一聚合 Apple/Google（未来可连 Stripe），状态同步与后台分析完善，Webhook 友好，大幅降低对账与边缘态处理复杂度。
   - 缺点：额外服务费用，极端自定义灵活性略受限。
   - 适用：快速上线与稳定运营，减少自研投入与风控成本。
3) Stripe Billing（预留未来多端）
   - 优点：订阅全栈成熟、税务与发票友好、多端支持强。
   - 说明：当前仅 iOS/Android，不在 App 内用于数字内容售卖（商店政策限制）；作为未来 Web/桌面扩展储备。
结论：V1 采用 IAP 合规路径，强烈推荐叠加 RevenueCat 以降低集成和对账复杂度；Stripe 暂缓，仅保留后续扩展选项。

## 10. 配额与计费细则
- 免费：注册首月赠送 5 次视频生成（仅扣减视频）。
- 订阅：$20/月，月配额 200 次，自然月重置，到期停用。
- 超额：Consumable 包（建议：$4.99/20 次、$9.99/50 次，最终以商店阶梯定价为准）。
- 服务端权威：所有扣减由服务端原子执行；失败回滚并记录审计；异常频率限速与黑名单策略。
- 防滥用：订阅用户每日软上限（如 40 次），异常触发验证或限流；设备与 IP 风控。

## 11. UI/UX 指南（暗色现代）
- 主题：Material 3 暗色，低饱和中性色 + 品牌强调色（蓝紫/青绿），统一圆角与阴影。
- 导航：底部 4 页签（首页、发现、创作、我的），视频生成功能突出入口。
- 识别页：大按钮拍摄/相册、上传进度、Top-K 卡片、失败重试与备用源切换。
- 百科页：信息分组（形态/习性/养护/毒性），季节/地区切片切换，来源徽章可点。
- 视频生成：参数侧栏 + 预览与进度条，顶部配额条，生成完成的快捷发布。
- 作品流：混排卡片、骨架屏、懒加载、双击点赞、内置分享。
- 付费墙：明确对比（免费 5 → 月 200 → 超额包）、常见问题、恢复购买与条款链接。


## 12. 运维与监控
- 指标：API QPS/延迟/错误率、队列长度、识别准确率、视频成功率、单位成本（$/视频）。
- 日志与审计：关键 Agent 决策链路落 `job_events`；PII 脱敏；异常采样。
- SLO：API P95 < 300ms（不含异步）；视频 T90 < 10 分钟。
- 弹性：队列并发/第三方配额自适应；失败指数退避；多供应商自动切换。

## 13. 里程碑（8–10 周）
- M1（第 1–2 周）基础闭环
  - App 壳 + PlantVision 清新主题（已完成） + 登录（已完成：完整实现 Apple/Google/邮箱/游客登录）
  - 首页设计（已完成：品牌展示、拍照识别、AI生成器、底部导航、历史记录）
  - 上传与识别（Plant.id）+ 百科展示（静态样例）（已完成：相机拍照、图片选择、模拟植物识别API、结果展示页面）
  - 后端服务架构（已完成：FastAPI + MySQL + Redis + Celery + Docker）
  - 数据库设计与迁移（已完成：用户、植物、媒体、订阅、社区等完整数据模型）
  - 对象存储与媒体链路打通
- M2（第 3–4 周）视频与配额
  - 异步队列、Replicate 集成、小流量 Pika A/B
  - 5 次免费 + 月配额权威扣减
- M3（第 5–6 周）订阅与支付
  - IAP 订阅与 Consumable 超额包、恢复购买
  - RevenueCat 聚合与服务端回调、票据校验与异常回退
- M4（第 7–8 周）社区与优化
  - 作品流/详情/互动、作者编辑与评论
  - 监控告警、崩溃上报、灰度发布、性能与成本护栏
- 预留：内容审核开关、数据源扩充与知识库治理

## 14. 验收标准（抽样）
- 商店审核通过（iOS/Android），合规项无阻。
- 全流程稳定：识别 → 百科 → 视频生成 → 发布 → 浏览 → 互动 成功率 ≥ 95%。
- 配额准确：5 次免费与月 200 扣减正确；超额包到账 ≤ 30s。
- 订阅一致：续费/取消/退款状态 T+0 同步；停订后无法继续生成视频。
- 知识可信：来源显示与可编辑；评论可用，违规内容可被标记（后台预留）。
- 成本可控：单位成本监控上线，异常自动限流/切换供应商。

## 15. 风险与缓解
- 第三方 API 波动/限额：多供应商冗余、指数退避、任务重试与降级策略。
- IAP 对账与欺诈：引入 RevenueCat；服务端票据校验与幂等、黑名单与风控评分。
- AI 成本外溢：每日用户软上限、动态质量档位与限速、低谷时段调度。
- 识别偏差：Top-K + 用户反馈；低置信度二次确认；社区纠错与专家编辑通道。
- 审核与合规：审核服务开关预留；最低限度图片/文本过滤上线前验证。

## 16. 与原型对齐
- 以 `zh-02.html` 的信息层级与导航布局为主；如与本计划冲突，以原型优先。
- 任务拆解阶段逐页核对：入口、交互、状态提示与错误处理文案一致。

## 17. 下一步待确认项
- 超额包面值与价格阶梯（建议：20/50 次）。
- 视频供应商主次顺序与预算上限（建议：主 Replicate，备 Pika；月度评估切主）。
- 开放数据源清单（优先 GBIF、USDA Plants、Wikidata、iNaturalist 导出）与许可说明。
- RevenueCat 是否立即引入；若否，需自建票据校验与订阅状态机的详细规则。


