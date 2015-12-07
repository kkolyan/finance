<%@ page import="org.springframework.web.context.WebApplicationContext" %>
<%@ page import="com.nplekhanov.finance.*" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.ZoneId" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title></title>
    <jsp:include page="css.jsp"/>
    <style>
        div.groups {
            text-indent: 20px;
        }
    </style>
</head>
<body>
<%@ include file="top.jsp"%>

<%

    WebApplicationContext context = WebApplicationContextUtils.getRequiredWebApplicationContext(application);
    Finances finances = context.getBean(Finances.class);

    String historyDaysText = request.getParameter("historyDays");
    int historyDays;
    if (historyDaysText == null) {
        historyDays = 10;
    } else {
        historyDays = Integer.parseInt(historyDaysText);
    }

    String focusedItemIdText = request.getParameter("focus");
    Long focusedItemId;
    if (focusedItemIdText != null) {
        focusedItemId = Long.parseLong(focusedItemIdText);
    } else {
        focusedItemId = 0L;
    }
    Long userId = (Long) session.getAttribute("userId");
    Group root = (Group) finances.getTransfer(focusedItemId, userId);
%>
<%
    {
        List<Item> path = new ArrayList<>(root.getPath());
        Collections.reverse(path);
        for (Item item: path) {
            %> <a href="add.jsp?focus=<%=item.getItemId()%>"><%= Escaping.safeHtml(item.getName())%></a> / <%
        }
        %><%= Escaping.safeHtml(root.getName())%> <%
    }
%> <div class="groups">
    <%
        for (Item child: root.getChildren()) {
            if (child instanceof Group && child.getItemId() >= 0) {
                %> <div class="group"> <a href="add.jsp?focus=<%=child.getItemId()%>"><%= Escaping.safeHtml(child.getName()) %></a></div>  <%
            }
        }
    %>
</div>
<div class="panel">
    <h4>Add Instant Transfer</h4>
    <form action="summary.jsp" method="post">
        <input type="hidden" name="action" value="CreateInstantTransfer"/>
        <input type="hidden" name="parent" value="<%=root.getItemId()%>"/>
        <input type="hidden" name="at" value="<%=Formats.DATE_TIME.format(LocalDate.now(ZoneId.of("Europe/Moscow")))%>"/>
        <label>
            Name
            <input name="name"/> (leave blank to use group name)
        </label>
        <label>
            Amount
            <input name="amount"/>
        </label>
        <input type="submit" value="Add"/>
    </form>
</div>
<div class="">
    <form>
        <input type="hidden" name="itemId" value="<%=root.getItemId()%>"/>
        <label>
            History for
            <input name="historyDays" value="<%=historyDays%>"/> days:
        </label>
    </form>
</div>
<div class="history">
    <%
        NavigableMap<LocalDate, List<InstantTransfer>> history = finances.loadHistory(userId);

        List<LocalDate> lastDays = new ArrayList<>(history.descendingKeySet());
        lastDays = lastDays.subList(0, historyDays);
        for (LocalDate date: lastDays) {
            %><div class="panel"> <h4><%=date.format(Formats.DATE_TIME)%></h4> <%

            for (InstantTransfer transfer: history.get(date)) {
                List<Item> path = transfer.getPath();
                Collections.reverse(path);
                %> <div>
                    <% for (Item pathItem: path) {%><%=Escaping.safeHtml(pathItem.getName())%> / <%}%>
                    <a href="summary.jsp?exploreFromSession=true&focus=<%=transfer.getItemId()%>"><%=Escaping.safeHtml(transfer.getName())%></a> :<b> <%=transfer.getAmount()%></b>
                </div> <%
            }
            %> </div> <%
        }
    %>
</div>

</body>
</html>
