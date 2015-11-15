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
    ul {
        /*padding: 0;*/
        margin: 0;
    }
    * {
        vertical-align: middle;
    }
    label {
        display: block;
    }

    fieldset {
        margin-top: 5px;
    }
</style>