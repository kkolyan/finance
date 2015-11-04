<%@ page import="com.nplekhanov.finance.Finances" %>
<%@ page import="com.nplekhanov.finance.Formats" %>
<%@ page import="com.nplekhanov.finance.Group" %>
<%@ page import="com.nplekhanov.finance.Item" %>
<%@ page import="org.springframework.web.context.WebApplicationContext" %>
<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils" %>
<%@ page import="static com.nplekhanov.finance.Escaping.safeHtml" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.YearMonth" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.Collection" %>
<%@ taglib prefix="fin" tagdir="/WEB-INF/tags" %>
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

    String action = request.getParameter("action");
    if (action != null) {
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
            YearMonth begin = YearMonth.parse(request.getParameter("begin"), DateTimeFormatter.ofPattern("yyyy-MM"));
            YearMonth end = YearMonth.parse(request.getParameter("end"), DateTimeFormatter.ofPattern("yyyy-MM"));
            Long parent = Long.parseLong(request.getParameter("parent"));

            finances.addMonthlyTransfer(name, amount, begin, end, parent);
        }
        if (action.equals("SetInitialBalance")) {
            long amount = Long.parseLong(request.getParameter("amount"));

            finances.setInitialBalance(amount);
        }

        response.sendRedirect(request.getContextPath()+request.getServletPath());
        return;
    }

    int selectSize = 16;
    Collection<Group> groups = finances.loadGroups();
%>
<html>
<head>
    <title></title>
    <style type="text/css">
        ul {
            /*padding: 0;*/
            margin: 0;
        }
        * {
            vertical-align: top;
        }
    </style>
</head>
<body>

<fieldset>
    <legend>New Group</legend>
    <form method="post">
        <input type="hidden" name="action" value="CreateGroup"/>
        <label>
            Name
            <input name="name"/>
        </label>
        <label>
            Parent
            <select name="parent" size="1">
                <%
                    for (Group group : groups) {
                %> <option value="<%=group.getItemId()%>"><%=getTreeFriendlyPath(group)%></option> <%
                }
            %>
            </select>
        </label>
        <input type="submit" value="Create"/>
    </form>
</fieldset>
<fieldset>
    <legend>Instant Transfer</legend>
    <fieldset>
        <legend>New</legend>
        <form method="post">
            <input type="hidden" name="action" value="CreateInstantTransfer"/>
            <label>
                Name
                <input name="name"/>
            </label>
            <label>
                Parent
                <select name="parent">
                    <%
                        for (Group group : groups) {
                    %> <option value="<%=group.getItemId()%>"><%=safeHtml(getTreeFriendlyPath(group))%></option> <%
                    }
                %>
                </select>
            </label>
            <label>
                Amount
                <input name="amount"/>
            </label>
            <label>
                At (yyyy-MM-dd)
                <input name="at" />
            </label>
            <input type="submit" value="Create"/>
        </form>
    </fieldset>
    <fieldset>
        <legend>Append to existing</legend>
        <form method="post">
            <input type="hidden" name="action" value="CreateInstantTransfer"/>
            <label>
                Item
                <select name="name">
                    <%
                        for (Group group : groups) {
                    %> <option value="<%=safeHtml(group.getName())%>"><%=safeHtml(getTreeFriendlyPath(group))%></option> <%
                    }
                %>
                </select>
            </label>
            <label>
                Amount
                <input name="amount"/>
            </label>
            <label>
                At (yyyy-MM-dd)
                <input name="at" />
            </label>
            <input type="submit" value="Append"/>
        </form>
    </fieldset>
</fieldset>
<fieldset>
    <legend>Monthly transfer</legend>
    <fieldset>
        <legend>New</legend>
        <form method="post">
            <input type="hidden" name="action" value="CreateMonthlyTransfer"/>
            <label>
                Name
                <input name="name"/>
            </label>
            <label>
                Parent
                <select name="parent">
                    <%
                        for (Group group : groups) {
                    %> <option value="<%=group.getItemId()%>"><%=safeHtml(getTreeFriendlyPath(group))%></option> <%
                    }
                %>
                </select>
            </label>
            <label>
                Amount
                <input name="amount"/>
            </label>
            <label>
                Begin (yyyy-MM)
                <input name="begin" />
            </label>
            <label>
                End (yyyy-MM)
                <input name="end" />
            </label>
            <input type="submit" value="Create"/>
        </form>
    </fieldset>
    <fieldset>
        <legend>Append to existing</legend>
        <form method="post">
            <input type="hidden" name="action" value="CreateMonthlyTransfer"/>
            <label>
                Item
                <select name="name">
                    <%
                        for (Group group : groups) {
                    %> <option value="<%=safeHtml(group.getName())%>"><%=safeHtml(getTreeFriendlyPath(group))%></option> <%
                    }
                %>
                </select>
            </label>
            <label>
                Amount
                <input name="amount"/>
            </label>
            <label>
                Begin (yyyy-MM)
                <input name="begin" />
            </label>
            <label>
                End (yyyy-MM)
                <input name="end" />
            </label>
            <input type="submit" value="Append"/>
        </form>
    </fieldset>
</fieldset>
<fieldset>
    <legend>Initial Balance</legend>
    <form method="post">
        <input type="hidden" name="action" value="SetInitialBalance"/>
        <label>
            Amount
            <input name="amount" value="<%=finances.loadInitialBalance()%>"/>
        </label>
        <input type="submit" value="Set"/>
    </form>
</fieldset>
</body>
</html>
