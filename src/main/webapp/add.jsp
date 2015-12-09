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

        #amountAbsInput {
            font: 14pt "Courier New";
            font-weight: 800;
            text-align: right;
        }
        a.active {
            font-weight: bold;
            color: black;
        }
        a.inactive {
            font-weight: normal;
            color: #CCCCCC;
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
    <h4>Добавить транзакцию</h4>
    <form id="add_form" action="summary.jsp" method="post">
        <input type="hidden" name="action" value="CreateInstantTransfer"/>
        <input type="hidden" name="parent" value="<%=root.getItemId()%>"/>
        <input type="hidden" name="at" value="<%=Formats.DATE_TIME.format(LocalDate.now(ZoneId.of("Europe/Moscow")))%>"/>
        <a id="amountSignMinus" class="active" href="javascript:;">Расход</a>
        <a id="amountSignPlus" class="inactive" href="javascript:;">Доход</a>
        <label>

            <input id="add_form_name" disabled name="name" value="<%=Escaping.safeHtml(root.getName())%>"/>
            <a id="add_form_name_enable" href="javascript:;">Дать название</a>
        </label>
        <input type="hidden" id="amountSignInput" name="amountSign" value="-"/>
        <input disabled id="amountAbsInput" name="amountAbs" value="0"/>
        <input type="hidden" id="amountInput" name="amount"/>
        <input style="display: none" type="submit" value="Submit" id="amountSubmit"/>
        <a id="amountPad_del" href="javascript:;">Коррекция</a>
        <div id="amountPad">
            <table>
                <tr><td class="amountPad_number">7</td><td class="amountPad_number">8</td><td class="amountPad_number">9</td></tr>
                <tr><td class="amountPad_number">4</td><td class="amountPad_number">5</td><td class="amountPad_number">6</td></tr>
                <tr><td class="amountPad_number">1</td><td class="amountPad_number">2</td><td class="amountPad_number">3</td></tr>
                <tr><td class="amountPad_number" colspan="2">0</td><td id="amountPad_ok"><b>Ok</b></td></tr>
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

            var amountSubmit = document.getElementById("amountSubmit");
            var amountPad = document.getElementById("amountPad");
            var amountInput = document.getElementById("amountInput");
            var amountAbsInput = document.getElementById("amountAbsInput");
            var amountSignInput = document.getElementById("amountSignInput");
            var cells = amountPad.getElementsByTagName("td");
            var numbers = document.getElementsByClassName("amountPad_number");
            function resizeAmountAbsInput() {
                amountAbsInput.size = Math.max((amountAbsInput.value+"").length, 6);
            }
            resizeAmountAbsInput();
            for (var i = 0; i < numbers.length; i ++) {
                numbers.item(i).onclick = function(event) {
                    var v = amountAbsInput.value;
                    var n = parseInt(event.target.innerHTML);
                    amountAbsInput.value = 10 * v + n;
                    resizeAmountAbsInput();
                };
            }
            document.getElementById("amountPad_del").onclick = function(event) {
                amountAbsInput.value = Math.floor(amountAbsInput.value / 10);
                resizeAmountAbsInput();
            };
            document.getElementById("amountPad_ok").onclick = function(event) {
                amountInput.value = (amountSignInput.value == "-" ? -1 : 1) * parseInt(amountAbsInput.value);
                add_form_name.disabled = false;
                document.getElementById("add_form").submit();
            };
            amountSubmit.onclick = document.getElementById("amountPad_ok").onclick;

            var amountSignPlus = document.getElementById("amountSignPlus");
            var amountSignMinus = document.getElementById("amountSignMinus");
            amountSignPlus.onclick = function() {
                amountSignPlus.className = "active";
                amountSignMinus.className = "inactive";
                amountSignInput.value = "+";
            };
            amountSignMinus.onclick = function() {
                amountSignMinus.className = "active";
                amountSignPlus.className = "inactive";
                amountSignInput.value = "-";
            };
        </script>
    </form>
</div>
<div class="">
    <form>
        <input type="hidden" name="itemId" value="<%=root.getItemId()%>"/>
        <label>
            История за
            <input name="historyDays" value="<%=historyDays%>"/> дней:
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
