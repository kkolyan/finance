<%@ page import="com.nplekhanov.finance.*" %>
<%@ page import="org.springframework.web.context.WebApplicationContext" %>
<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils" %>
<%@ page import="static com.nplekhanov.finance.Escaping.*" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.YearMonth" %>
<%@ page import="java.time.ZoneId" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fin" tagdir="/WEB-INF/tags" %>
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
        if (action.equals("CreateGroup")) {
            String name = request.getParameter("name");
            Long parent = Long.parseLong(request.getParameter("parent"));
            finances.createGroup(name, parent);
        }
        if (action.equals("SetParent")) {
            Long item = Long.parseLong(request.getParameter("item"));
            Long parent = Long.parseLong(request.getParameter("parent"));
            finances.associate(item, parent);
        }
        if (action.equals("CreateInstantTransfer")) {
            String name = request.getParameter("name");
            long amount = Long.parseLong(request.getParameter("amount"));
            LocalDate at = LocalDate.parse(request.getParameter("at"), Formats.DATE_TIME);
            Long parent;
            if (request.getParameter("parent") != null) {
                parent = Long.parseLong(request.getParameter("parent"));
            } else {
                parent = null;
            }

            finances.addInstantTransfer(name, amount, at, parent);
        }
        if (action.equals("CreateMonthlyTransfer")) {
            String name = request.getParameter("name");
            long amount = Long.parseLong(request.getParameter("amount"));
            YearMonth begin = YearMonth.parse(request.getParameter("begin"), Formats.YEAR_MONTH);
            YearMonth end = YearMonth.parse(request.getParameter("end"), Formats.YEAR_MONTH);
            Long parent = Long.parseLong(request.getParameter("parent"));

            finances.addMonthlyTransfer(name, amount, begin, end, parent);
        }
        response.sendRedirect(request.getContextPath()+request.getServletPath()+"?"+request.getQueryString());
        return;
    }
    Collection<Group> groups = finances.loadGroups();
%>
<%
    Collection<YearMonth> futureMonths = new TreeSet<>();
    for (int i = 0; i < 24; i ++) {
        futureMonths.add(YearMonth.now().plusMonths(i + 1));
    }
%>
<html>
<head>
    <title></title>
    <jsp:include page="css.jsp"/>
    <style>
        * {
            vertical-align: top;
        }

        label {
            display: block;
        }
    </style>
</head>
<body>
<jsp:include page="top.jsp"/>

<fieldset>
    <legend>
        <%
            List<Item> path = new ArrayList<>(transfer.getPath());
            Collections.reverse(path);
            for (Item parent: path) {
                if (parent.getParentItemId() == null) {
                    %><a href="summary.jsp?exploreFromSession=true"><%= parent.getName()%></a> / <%
                } else {
                    %><a href="transfer.jsp?transferId=<%=parent.getItemId()%>"><%= parent.getName()%></a> / <%
                }
        }
        %>
        <%=safeHtml(transfer.getName())%> #<%=transferId%>
    </legend>
    <%
    if (transfer instanceof Group) {
        %>
        <fieldset>
            <legend>Children</legend>
            <fin:items-tree item="<%= transfer %>"/>
        </fieldset>
        <%
    }
    %>
    <fieldset>
        <legend>Attributes</legend>
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
    </fieldset>
    <%
    if (transfer instanceof Group) {
        %>

            <fieldset>
                <legend>Instant Transfer</legend>
                <form method="post">
                    <input type="hidden" name="action" value="CreateInstantTransfer"/>
                    <input type="hidden" name="parent" value="<%=transfer.getItemId()%>"/>
                    <label>
                        Name
                        <input name="name"/>
                    </label>
                    <label>
                        Amount
                        <input name="amount"/>
                    </label>
                    <label>
                        At (yyyy-MM-dd)
                        <input name="at" value="<%=Formats.DATE_TIME.format(LocalDate.now(ZoneId.of("Europe/Moscow")))%>"/>
                    </label>
                    <input type="submit" value="Add"/>
                </form>
            </fieldset>
            <fieldset>
                <legend>Monthly transfer</legend>
                <form method="post">
                    <input type="hidden" name="action" value="CreateMonthlyTransfer"/>
                    <input type="hidden" name="parent" value="<%=transfer.getItemId()%>"/>
                    <label>
                        Name
                        <input name="name"/>
                    </label>
                    <label>
                        Amount
                        <input name="amount"/>
                    </label>
                    <label>
                        Begin (yyyy-MM)
                        <select name="begin" >
                            <%
                                for (YearMonth month: futureMonths) {
                            %><option><%=month.format(Formats.YEAR_MONTH)%></option> <%
                            }
                        %>
                        </select>
                    </label>
                    <label>
                        End (yyyy-MM)
                        <select name="end">
                            <%
                                for (YearMonth month: futureMonths) {
                            %><option><%=month.format(Formats.YEAR_MONTH)%></option> <%
                            }
                        %>
                        </select>
                    </label>
                    <input type="submit" value="Add"/>
                </form>
            </fieldset>
            <fieldset>
                <legend>New Group</legend>
                <form method="post">
                    <input type="hidden" name="action" value="CreateGroup"/>
                    <input type="hidden" name="parent" value="<%=transfer.getItemId()%>"/>
                    <label>
                        Name
                        <input name="name"/>
                    </label>
                    <input type="submit" value="Add"/>
                </form>
            </fieldset>
        <%
    }
    %>
    <br/>
    <form method="post" action="delete.jsp">
        <input type="hidden" name="transferId" value="<%=transferId%>">
        <input type="hidden" name="referrer" value="<%=Escaping.safeHtml(request.getContextPath()+request.getServletPath()+"?"+request.getQueryString())%>"/>
        <input type="hidden" name="parentPage" value="<%=Escaping.safeHtml(request.getContextPath()+request.getServletPath()+"?transferId="+transfer.getParentItemId())%>"/>
        <input type="submit" value="Delete"/>
    </form>
</fieldset>

</body>
</html>
