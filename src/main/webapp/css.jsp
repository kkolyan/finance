<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<style type="text/css" rel="stylesheet">
    div.menu {
        float: right;
    }
    <%
        String userAgent = request.getHeader("user-agent");
        if (userAgent.contains("Android") || userAgent.contains("iPhone")) {
            %>
            body {
                zoom: 4;
            }
            div.menu {
                float: none;
                text-align: right;
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
        white-space: nowrap;
    }
    table {
        border-collapse: collapse;
    }
    td, th {
        border: solid 1px #ccc;
    }
    th {
        background-color: #eee;
    }
    label {
        display: block;
    }

    fieldset {
        margin-top: 5px;
    }

    a.img {
        text-decoration: none;
    }

    div.editor {
        border: 1px solid #CCC;
        padding: 0 10px;
        margin-top: 5px;
        margin-right: 10px;
        margin-left: 0;
        margin-bottom: 5px;
        float: left;
    }
    div.editor h4 {
        margin: 5px 0;
    }

    div.panel {
        border-left: 1px solid #CCC;
        border-top: 1px solid #CCC;
        padding: 0 10px;
        margin-top: 5px;
        margin-right: 10px;
        margin-left: 0;
        margin-bottom: 5px;
    }
    div.panel h4 {
        margin: 5px 0;
    }
</style>