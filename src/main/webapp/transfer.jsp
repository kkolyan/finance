<%@ page import="com.nplekhanov.finance.*" %>
<%@ page import="org.springframework.web.context.WebApplicationContext" %>
<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils" %>
<%@ page import="static com.nplekhanov.finance.Escaping.*" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.YearMonth" %>
<%@ page import="java.util.Collection" %>
<%@ page import="java.util.Objects" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%!
    String getTreeFriendlyPath(Group item) {

        int parentPathLength = item.getPath().size();

        StringBuilder s = new StringBuilder();
        for (int i = 0; i < parentPathLength; i ++) {
            s.append("&nbsp;&nbsp;&nbsp;&nbsp;");
        }
        return s.append(item.getName()).toString();
    }
%>
<%

    WebApplicationContext context = WebApplicationContextUtils.getRequiredWebApplicationContext(application);
    Finances finances = context.getBean(Finances.class);
    long transferId = Long.parseLong(request.getParameter("transferId"));
    Item transfer = finances.getTransfer(transferId);

    String action = request.getParameter("action");
    if (request.getMethod().equalsIgnoreCase("POST")) {
        if (action.equals("DeleteItem")) {
            finances.deleteItem(transferId);
        }
        if (action.equals("ModifyItem")) {
            long parent = Long.parseLong(request.getParameter("parent"));
            String name = request.getParameter("name");

            String atText = request.getParameter("at");
            String beginText = request.getParameter("begin");
            if (atText != null) {
                long amount = Long.parseLong(request.getParameter("amount"));
                LocalDate at = LocalDate.parse(atText, Formats.DATE_TIME);
                finances.modifyTransfer(transferId, at, amount, name, parent);
            } else if (beginText != null) {
                long amount = Long.parseLong(request.getParameter("amount"));
                YearMonth begin = YearMonth.parse(beginText, Formats.YEAR_MONTH);
                YearMonth end = YearMonth.parse(request.getParameter("end"), Formats.YEAR_MONTH);
                finances.modifyTransfer(transferId, begin, end, amount, name, parent);
            } else {
                finances.modifyGroup(transferId, name, parent);
            }
        }
        response.sendRedirect(request.getContextPath()+request.getServletPath()+"?"+request.getQueryString());
        return;
    }
    Collection<Group> groups = finances.loadGroups();
%>
<html>
<head>
    <meta name="viewport" content="width=device-width">
    <title></title>
    <style>
        * {
            vertical-align: top;
        }
    </style>
</head>
<body>
<jsp:include page="top.jsp"/>

<fieldset>
    <legend><%=safeHtml(transfer)%> #<%=transferId%></legend>
    <form method="post">
        <input type="hidden" name="transferId" value="<%=transferId%>">
        <input type="hidden" name="action" value="ModifyItem">
        <label>
            Name
            <input name="name" size="200" value="<%=Escaping.safeHtml(transfer.getName())%>"/>
        </label>
        <br/>
        <%
        if (transfer instanceof InstantTransfer) {
            %>
            <label>
                At (<%= Formats.DATE_TIME_PATTERN %>)
                <input name="at" value="<%= ((InstantTransfer)transfer).getAt().format(Formats.DATE_TIME)%>"/>
            </label>
            <br/>
            <label>
                Amount
                <input name="amount" value="<%=((InstantTransfer)transfer).getAmount()%>"/>
            </label>
            <br/>
            <%
        } else if (transfer instanceof MonthlyPlannedTransfer) {
            %>
            <label>
                Begin (<%= Formats.YEAR_MONTH_PATTERN %>)
                <input name="begin" value="<%= ((MonthlyPlannedTransfer)transfer).getBegin().format(Formats.YEAR_MONTH)%>"/>
            </label>
            <br/>
            <label>
                End (<%= Formats.YEAR_MONTH_PATTERN %>)
                <input name="end" value="<%= ((MonthlyPlannedTransfer)transfer).getEnd().format(Formats.YEAR_MONTH)%>"/>
            </label>
            <br/>
            <label>
                Amount
                <input name="amount" value="<%=((MonthlyPlannedTransfer)transfer).getAmount()%>"/>
            </label>
            <br/>
            <%
        }
        %>
        <label>
            Parent
            <select name="parent" size="20">
                <%
                    for (Group group : groups) {
                        %> <option <%if (Objects.equals(group.getItemId(), transfer.getParentItemId())) {%> selected="selected" <%}%> value="<%=group.getItemId()%>"><%=safeHtml(getTreeFriendlyPath(group))%></option> <%
                    }
                %>
            </select>
        </label>
        <br/>
        <input type="submit" value="Save"/>
    </form>
    <form method="post">
        <input type="hidden" name="transferId" value="<%=transferId%>">
        <input type="hidden" name="action" value="DeleteItem">
        <input type="submit" value="Delete"/>
    </form>
</fieldset>

</body>
</html>
