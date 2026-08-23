---
menu_id: workouts
title: ''
date: 2026-08-23 12:00:00
comment: false
breadcrumb: false
rightbar: ''
inject:
  head:
    - |
      <style>
      /* 全屏嵌入页：回收右侧栏空间，主内容铺满可用宽度 */
      .l_body:has(#workout-dashboard) {
        grid-template-columns: auto minmax(0, 1fr);
      }
      .l_body:has(#workout-dashboard) .l_right {
        display: none;
      }
      .l_body:has(#workout-dashboard) .float-panel {
        grid-column-end: span 2;
      }
      .l_body:has(#workout-dashboard) .md-text.content {
        padding: 0;
      }
      .l_body:has(#workout-dashboard) .page-footer {
        display: none;
      }
      </style>
---

<iframe
  id="workout-dashboard"
  title="Workout Dashboard"
  src="https://zhaohongxuan.github.io/workouts"
  style="width:100%;height:calc(100vh - var(--gap-page) * 2);border:0;border-radius:8px;background:#fff;display:block"
  loading="lazy"
></iframe>
