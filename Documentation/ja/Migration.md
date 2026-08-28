# 移行

既存イベントを安定 ID とソートキーを持つ `KLCalendarLaneEvent` へ変換します。UI メタデータは ID をキーにしたホスト側の表へ残します。週または月の区間でエンジンを呼び、返されたセグメントを描画用モデルへ写し、単日 chip の前に `coveredLaneCount(on:)` を使います。既存の終了日規則に合わせて `.exclusive` または `.inclusive` を明示します。
