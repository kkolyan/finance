<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils" %>
<%@ page import="org.springframework.web.context.WebApplicationContext" %>
<%@ page import="java.util.Collection" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.YearMonth" %>
<%@ page import="static com.nplekhanov.finance.Escaping.safeHtml" %>
<%@ page import="com.nplekhanov.finance.*" %>
<%@ taglib prefix="fin" tagdir="/WEB-INF/tags" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%!
    String getTreeFriendlyPath(Item item) {

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

    Collection<Item> shallowItems = finances.loadShallowItems();

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
                    for (Item item: shallowItems) {
                %> <option value="<%=item.getItemId()%>"><%=getTreeFriendlyPath(item)%></option> <%
                }
            %>
            </select>
        </label>
        <input type="submit" value="Create"/>
    </form>
</fieldset>
<fieldset>
    <legend>Edit Hierarchy</legend>
    <form method="post">
        <input type="hidden" name="action" value="SetParent"/>
        <label>
            Item
            <select name="item" size="<%=selectSize%>">
                <%
                    for (Item item: shallowItems) {
                %> <option value="<%=item.getItemId()%>"><%=getTreeFriendlyPath(item)%></option> <%
                }
            %>
            </select>
        </label>
        <label>
            Parent
            <select name="parent" size="<%=selectSize%>">
                <%
                    for (Item item: shallowItems) {
                %> <option value="<%=item.getItemId()%>"><%=safeHtml(getTreeFriendlyPath(item))%></option> <%
                }
            %>
            </select>
        </label>
        <input type="submit" value="Associate"/>
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
                        for (Item item: shallowItems) {
                    %> <option value="<%=item.getItemId()%>"><%=safeHtml(getTreeFriendlyPath(item))%></option> <%
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
                        for (Item item: shallowItems) {
                    %> <option value="<%=safeHtml(item.getName())%>"><%=safeHtml(getTreeFriendlyPath(item))%></option> <%
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
                        for (Item item: shallowItems) {
                    %> <option value="<%=item.getItemId()%>"><%=safeHtml(getTreeFriendlyPath(item))%></option> <%
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
                        for (Item item: shallowItems) {
                    %> <option value="<%=safeHtml(item.getName())%>"><%=safeHtml(getTreeFriendlyPath(item))%></option> <%
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
