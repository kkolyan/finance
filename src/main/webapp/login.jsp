<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils" %>
<%@ page import="com.nplekhanov.finance.Users" %>
<%@ page import="com.nplekhanov.finance.Invitation" %>
<%@ page import="com.nplekhanov.finance.Escaping" %>
<%@ page import="com.nplekhanov.finance.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title></title>
    <jsp:include page="css.jsp"/>
</head>
<body>
<%
    Users users = WebApplicationContextUtils.getRequiredWebApplicationContext(application).getBean(Users.class);
    if (request.getMethod().equalsIgnoreCase("post")) {

        String name = request.getParameter("name");
        String password = request.getParameter("password");

        User user = users.authenticate(name, password);

        if (user == null) {
            response.sendError(403);
            return;
        }

        request.getSession().setAttribute("userId", user.getId());

        response.sendRedirect(request.getContextPath());
        return;
    }
%>
<form method="post">
    <label>
        Name
        <input name="name"/>
    </label>
    <label>
        Password
        <input type="password" name="password"/>
    </label>
    <input type="submit" value="Log in"/>
</form>
</body>
</html>
