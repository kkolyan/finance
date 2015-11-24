<%@ page import="org.springframework.context.ApplicationContext" %>
<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils" %>
<%@ page import="com.nplekhanov.finance.Backup" %>
<%@ page import="com.nplekhanov.finance.Escaping" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title></title>
</head>
<body>

<%
    ApplicationContext context = WebApplicationContextUtils.getRequiredWebApplicationContext(application);
    Backup backup = context.getBean(Backup.class);
    String encoding = request.getParameter("encoding");
    if (encoding == null) {
        encoding = "UTF-8";
    }
    String dump = backup.createDump(encoding);%>

<pre>
<%=Escaping.safeHtml(dump)%>
</pre>

</body>
</html>
