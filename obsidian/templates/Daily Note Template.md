---
tags:
  - daily
  - note
modified: <% tp.file.creation_date("YYYY-MM-DD hh:mm A") %>
created: <% tp.file.creation_date("YYYY-MM-DD hh:mm A") %>
---
# <% moment(tp.file.title,'YYYY-MM-DD').format("dddd, MMMM DD, YYYY") %>

⬅️️ [[Daily Notes/<% tp.date.now("YYYY", -1, tp.file.title, "YYYY-MM-DD dddd") %>/<% tp.date.now("MM MMMM", -1, tp.file.title, "YYYY-MM-DD dddd") %>/<% tp.date.now("YYYY-MM-DD dddd", -1, tp.file.title, "YYYY-MM-DD dddd") %>|Yesterday]] | [[Daily Notes/<% tp.date.now("YYYY", 1, tp.file.title, "YYYY-MM-DD dddd") %>/<% tp.date.now("MM MMMM", 1, tp.file.title, "YYYY-MM-DD dddd") %>/<% tp.date.now("YYYY-MM-DD dddd", 1, tp.file.title, "YYYY-MM-DD dddd") %>|Tomorrow]] ➡️️
## 🪶️ Daily Quote

<%*  
const { Widgets } = await cJS();
// Resolve the Promise to get the string
const dailyQuote = await tp.web.daily_quote();
// Pass the resolved string and append the result
tR += Widgets.daily_quote(dailyQuote);
%>

---
## ☑️️ Tasks

- [ ] Task

---
## 📝  Notes

<% tp.file.cursor() %>

---
## ✅️  Tasks Completed Today
```tasks
done on "<%tp.file.title.substring(0,10)%>"
```
## 📕️ Notes Created Today
```dataview
List FROM "" WHERE file.cday = date("<%tp.file.title.substring(0,10)%>") SORT file.ctime asc
```
## 📘️ Notes Modified Today
```dataview
List FROM "" WHERE file.mday = date("<%tp.file.title.substring(0,10)%>") SORT file.mtime asc
```