# 迁移

将现有事件映射为带稳定 ID 和排序键的 `KLCalendarLaneEvent`。将 UI 元数据留在以 ID 为键的宿主查找表中。对当前周或月调用引擎，映射返回分段，并在放置单日 chip 前读取 `coveredLaneCount(on:)`。请显式选择与现有结束日期规则一致的 `.exclusive` 或 `.inclusive`。
