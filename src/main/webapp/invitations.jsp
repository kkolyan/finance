<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils" %>
<%@ page import="com.nplekhanov.finance.Users" %>
<%@ page import="com.nplekhanov.finance.Invitation" %>
<%@ page import="com.nplekhanov.finance.Escaping" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Users users = WebApplicationContextUtils.getRequiredWebApplicationContext(application).getBean(Users.class);

    if (request.getMethod().equalsIgnoreCase("post")) {

        users.invite(request.getParameter("description"));

        response.sendRedirect(request.getContextPath()+request.getServletPath()+"?"+request.getQueryString());
        return;
    }
%>
<html>
<head>
    <title></title>
    <jsp:include page="css.jsp"/>
</head>
<body>
<form method="post">
    <input type="hidden" name="action" value="Invite"/>
    <label>
        Description
        <input name="description"/>
    </label>
    <input type="submit" value="Invite"/>
</form>
<table>
    <tr>
        <th>Code</th>
        <th>Description</th>
        <th>Invited At</th>
        <th>Registered At</th>
    </tr>
    <%

        for (Invitation invitation: users.getInvitations()) {
            %>
            <tr>
                <td><a href="register.jsp?code=<%=Escaping.safeHtml(invitation.getCode())%>"><%=Escaping.safeHtml(invitation.getCode())%></a> </td>
                <td><%=Escaping.safeHtml(invitation.getDescription())%></td>
                <td><%=Escaping.safeHtml(invitation.getInvitedAt())%></td>
                <td><%=Escaping.safeHtml(invitation.getRegisteredAt())%></td>
            </tr>
            <%
        }
    %>
</table>
</body>
</html>
