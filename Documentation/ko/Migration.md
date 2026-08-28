# 마이그레이션

기존 이벤트를 안정 ID와 정렬 키를 가진 `KLCalendarLaneEvent`로 매핑합니다. UI 메타데이터는 ID를 키로 하는 호스트 조회표에 둡니다. 주 또는 월 구간에 대해 엔진을 호출하고 반환된 세그먼트를 그리며 단일 날짜 chip 전에 `coveredLaneCount(on:)`을 사용합니다. 기존 종료일 규칙에 맞게 `.exclusive` 또는 `.inclusive`를 명시적으로 선택합니다.
