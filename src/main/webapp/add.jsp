<%@ page import="org.springframework.web.context.WebApplicationContext" %>
<%@ page import="com.nplekhanov.finance.*" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.ZoneId" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title></title>
    <jsp:include page="css.jsp"/>
    <style>
        div.groups {
            text-indent: 20px;
        }

        * {
            white-space: normal;
        }

        div.history-odd {
            background-color: #f2f2f2;
        }

        #amountInput {
            font: 18pt "Courier New";
            font-weight: 800;
        }
    </style>
</head>
<body>
<%@ include file="top.jsp"%>

<%

    WebApplicationContext context = WebApplicationContextUtils.getRequiredWebApplicationContext(application);
    Finances finances = context.getBean(Finances.class);

    String historyDaysText = request.getParameter("historyDays");
    int historyDays;
    if (historyDaysText == null) {
        historyDays = 10;
    } else {
        historyDays = Integer.parseInt(historyDaysText);
    }

    String focusedItemIdText = request.getParameter("focus");
    Long focusedItemId;
    if (focusedItemIdText != null) {
        focusedItemId = Long.parseLong(focusedItemIdText);
    } else {
        focusedItemId = 0L;
    }
    Long userId = (Long) session.getAttribute("userId");
    Group root = (Group) finances.getTransfer(focusedItemId, userId);
%>
<%
    {
        List<Item> path = new ArrayList<>(root.getPath());
        Collections.reverse(path);
        for (Item item: path) {
            %> <a href="add.jsp?focus=<%=item.getItemId()%>"><%= Escaping.safeHtml(item.getName())%></a> / <%
        }
        %><%= Escaping.safeHtml(root.getName())%> <%
    }
%> <div class="groups">
    <%
        for (Item child: root.getChildren()) {
            if (child instanceof Group && child.getItemId() >= 0) {
                %> <div class="group"> <a href="add.jsp?focus=<%=child.getItemId()%>"><%= Escaping.safeHtml(child.getName()) %></a></div>  <%
            }
        }
    %>
</div>
<div class="panel">
    <h4>Add Instant Transfer</h4>
    <form id="add_form" action="summary.jsp" method="post">
        <input type="hidden" name="action" value="CreateInstantTransfer"/>
        <input type="hidden" name="parent" value="<%=root.getItemId()%>"/>
        <input type="hidden" name="at" value="<%=Formats.DATE_TIME.format(LocalDate.now(ZoneId.of("Europe/Moscow")))%>"/>
        <label>

            <input id="add_form_name" disabled name="name" value="<%=Escaping.safeHtml(root.getName())%>"/>
            <a id="add_form_name_enable" href="javascript:;">Custom</a>
        </label>
        <input disabled id="amountInput" name="amount" value="0" size="10"/>
        <a id="amountPad_del" href="javascript:;">Correct</a>
        <div id="amountPad">
            <table>
                <tr><td class="amountPad_number">7</td><td class="amountPad_number">8</td><td class="amountPad_number">9</td></tr>
                <tr><td class="amountPad_number">4</td><td class="amountPad_number">5</td><td class="amountPad_number">6</td></tr>
                <tr><td class="amountPad_number">1</td><td class="amountPad_number">2</td><td class="amountPad_number">3</td></tr>
                <tr><td id="amountPad_minus">-</td><td class="amountPad_number">0</td><td id="amountPad_ok"><b>Ok</b></td></tr>
            </table>
        </div>
        <script type="text/javascript">
            var add_form_name = document.getElementById("add_form_name");
            document.getElementById("add_form_name_enable").onclick = function(event) {
                if (add_form_name.disabled) {
                    add_form_name.disabled = false;
                    add_form_name.value = "";
                    add_form_name.focus();
                    event.target.innerHTML = "Use group name";
                } else {
                    add_form_name.disabled = true;
                    add_form_name.value = "<%=Escaping.safeHtml(root.getName())%>";
                    event.target.innerHTML = "Custom";
                }
            };

            var amountPad = document.getElementById("amountPad");
            var amountInput = document.getElementById("amountInput");
            var cells = amountPad.getElementsByTagName("td");
            var numbers = document.getElementsByClassName("amountPad_number");
            for (var i = 0; i < numbers.length; i ++) {
                numbers.item(i).onclick = function(event) {
                    var v = amountInput.value;
                    var n = parseInt(event.target.innerHTML);
                    amountInput.value = 10 * v + n;
                };
            }
            document.getElementById("amountPad_del").onclick = function(event) {
                amountInput.value = Math.floor(amountInput.value / 10);
            };
            document.getElementById("amountPad_ok").onclick = function(event) {
                amountInput.disabled = false;
                add_form_name.disabled = false;
                document.getElementById("add_form").submit();
            };
            document.getElementById("amountPad_minus").onclick = function(event) {
                amountInput.value = - parseInt(amountInput.value);
            };
        </script>
    </form>
</div>
<div class="">
    <form>
        <input type="hidden" name="itemId" value="<%=root.getItemId()%>"/>
        <label>
            History for
            <input name="historyDays" value="<%=historyDays%>"/> days:
        </label>
    </form>
</div>
<div class="history">
    <%
        NavigableMap<LocalDate, List<InstantTransfer>> history = finances.loadHistory(userId);

        List<LocalDate> lastDays = new ArrayList<>(history.descendingKeySet());
        lastDays = lastDays.subList(0, Math.min(historyDays, lastDays.size()));
        int n = 0;
        for (LocalDate date: lastDays) {
            %><div class="panel"> <h4><%=date.format(Formats.DATE_TIME)%></h4> <%

            for (InstantTransfer transfer: history.get(date)) {
                List<Item> path = transfer.getPath();
                Collections.reverse(path);
                %> <div class="<% if (n % 2 == 0) {%> history-odd <%} else {%> history-even <%}%>">
                    <% for (Item pathItem: path) {%><%=Escaping.safeHtml(pathItem.getName())%> / <%}%>
                    <a href="summary.jsp?exploreFromSession=true&focus=<%=transfer.getItemId()%>"><%=Escaping.safeHtml(transfer.getName())%></a> :<b> <%=transfer.getAmount()%></b>
                </div> <%
                n ++;
            }
            %> </div> <%
        }
    %>
</div>

</body>
</html>
