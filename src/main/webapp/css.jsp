<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<style type="text/css" rel="stylesheet">
    <%
        String userAgent = request.getHeader("user-agent");
        if (userAgent.contains("Android")) {
    %>
    * {
        white-space: nowrap;
    }
    body {
        zoom: 4;
    }
    <%
        }
    %>
</style>