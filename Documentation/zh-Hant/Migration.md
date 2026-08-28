# 遷移

把既有事件映射為具有穩定 ID 和排序鍵的 `KLCalendarLaneEvent`。將 UI 中繼資料保留在以 ID 為鍵的宿主查找表。對目前週或月呼叫引擎，映射回傳分段，並在放置單日 chip 前讀取 `coveredLaneCount(on:)`。請明確選擇符合既有結束日期規則的 `.exclusive` 或 `.inclusive`。
