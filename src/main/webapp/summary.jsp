<%@ page import="org.springframework.util.StringUtils" %>
<%@ page import="org.springframework.web.context.WebApplicationContext" %>
<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils" %>
<%@ page import="java.time.format.TextStyle" %>
<%@ page import="java.util.*" %>
<%@ page import="com.nplekhanov.finance.*" %>
<%@ page import="java.time.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title></title>
    <jsp:include page="css.jsp"/>
    <style>
        .even td, .even th {
            border: 1px solid #CCC;
            padding: 1px 5px;
            /*min-width: 240px;*/
        }
        .odd td, .odd th {
            border: 1px solid #CCC;
            padding: 1px 5px;
            /*min-width: 240px;*/
            background-color: #f6f6f6;
        }
        td,th {
            border: 1px solid #CCC;
            padding: 1px 5px;
            /*min-width: 240px;*/
        }

        .even td.positive {
            background-color: rgb(235, 255, 235);
        }
        .even td.current-month {
            background-color: rgb(255, 250, 236);
        }
        .even td.positive.current-month {
            background-color: rgb(240, 253, 235);
        }
        .even th.current-month {
            background-color: rgb(223, 220, 213);
        }
        .odd td.positive {
            background-color: rgb(225, 245, 225);
        }
        .odd td.current-month {
            background-color: rgb(241, 236, 222);
        }
        .odd td.positive.current-month {
            background-color: rgb(230, 243, 225);
        }
        .odd th.current-month {
            background-color: rgb(223, 220, 213);
        }

        th {
            white-space: nowrap;
            background: rgb(238, 238, 238);
            font-size: 11pt;
        }

        th.month {
            font-weight: normal;
        }

        .offer-field-type {
            color: #5a0a04;
        }
        .offer-field-subtitle {
            color: #2634a6;
        }
        .transfer-actual { color: black; }
        .transfer-planned { color: #a3a3a3; font-weight: 300; }
        .transfer-estimated { color: #7c96d1 }
        .transfer-corrected { color: #485dc4; font-weight: 300; }
        .transfer-mixed { color: #8a0b05; font-weight: 300; }

        td.amount {
            text-align: right;
            font: 'Courier New';
        }

        th.balance {
            text-align: right;
            font-size: 10pt;
            font-weight: normal;
        }

        th.balance_actual {
            font-weight: bold;
        }

        th.annual {
            text-align: right;
            font-weight: normal;
        }

    </style>
</head>
<body>
<%@ include file="top.jsp"%>
<%!
    String formatNumber(Long o) {
        if (o.equals(0L)) {
            return "";
        }
        return String.format("%,d", o);
    }

    String getClassByAmountTypes(Collection<AmountType> amountTypes) {
        if (amountTypes.isEmpty()) {
            return "";
        }
        if (amountTypes.size() == 1) {
            return "transfer-"+amountTypes.iterator().next().name().toLowerCase();
        }
        return "transfer-mixed";
    }

    String getTreeFriendlyPath(Group item) {

        int parentPathLength = item.getPath().size();

        StringBuilder s = new StringBuilder();
        for (int i = 0; i < parentPathLength; i ++) {
            s.append("&nbsp;&nbsp;&nbsp;&nbsp;");
        }
        return s.append(item.getName()).toString();
    }

    String createParams(HttpServletRequest request, Year toggleYear, Long toggleCategory, Long focusOnItem) {

        String[] yearsText = request.getParameterValues("year");
        String[] categoriesText = request.getParameterValues("explore");

        boolean exploreFromSession = "true".equals(request.getParameter("exploreFromSession"));
        if (exploreFromSession) {
            yearsText = (String[]) request.getSession().getAttribute("year");
            categoriesText = (String[]) request.getSession().getAttribute("explore");
        }

        Set<Year> yearsToShow = new TreeSet<>();
        Set<Long> categoriesToExplore = new TreeSet<>();
        if (yearsText != null) {
            for (String param: yearsText) {
                yearsToShow.add(Year.parse(param));
            }
        }
        if (categoriesText != null) {
            for (String param: categoriesText) {
                categoriesToExplore.add(Long.parseLong(param));
            }
        }

        if (toggleYear != null) {
            if (yearsToShow.contains(toggleYear)) {
                yearsToShow.remove(toggleYear);
            } else {
                yearsToShow.add(toggleYear);
            }
        }
        if (toggleCategory != null) {
            if (categoriesToExplore.contains(toggleCategory)) {
                categoriesToExplore.remove(toggleCategory);
            } else {
                categoriesToExplore.add(toggleCategory);
            }
        }
        Collection<String> entries = new ArrayList<String>();
        if (focusOnItem != null && !focusOnItem.equals(0L)) {
            entries.add("focus="+focusOnItem);
        }
        for (Year y: yearsToShow) {
            entries.add("year="+ y);
        }
        for (Long itemId: categoriesToExplore) {
            entries.add("explore="+ itemId);
        }
        return StringUtils.collectionToDelimitedString(entries, "&");
    }
%>
<%
    WebApplicationContext context = WebApplicationContextUtils.getRequiredWebApplicationContext(application);
    Finances finances = context.getBean(Finances.class);
    BalanceCorrection correction = context.getBean(BalanceCorrection.class);

    String focusedItemIdText = request.getParameter("focus");
    Long focusedItemId;
    if (focusedItemIdText != null) {
        focusedItemId = Long.parseLong(focusedItemIdText);
    } else {
        focusedItemId = 0L;
    }
    Long userId = (Long) session.getAttribute("userId");
    Item root = finances.getTransfer(focusedItemId, userId);

    String action = request.getParameter("action");
    if (request.getMethod().equalsIgnoreCase("POST")) {
        if (action.equals("ModifyItem")) {
            if (root.getItemId() == 0) {
                throw new IllegalStateException();
            }
            long parent = Long.parseLong(request.getParameter("parent"));
            String name = request.getParameter("name");

            String atText = request.getParameter("at");
            String beginText = request.getParameter("begin");
            if (atText != null) {
                long amount = Long.parseLong(request.getParameter("amount"));
                LocalDate at = LocalDate.parse(atText, Formats.DATE_TIME);
                finances.modifyTransfer(root.getItemId(), at, amount, name, parent, userId);
            } else if (beginText != null) {
                long amount = Long.parseLong(request.getParameter("amount"));
                YearMonth begin = YearMonth.parse(beginText, Formats.YEAR_MONTH);
                YearMonth end = YearMonth.parse(request.getParameter("end"), Formats.YEAR_MONTH);
                finances.modifyTransfer(root.getItemId(), begin, end, amount, name, parent, userId);
            } else {
                finances.modifyGroup(root.getItemId(), name, parent, userId);
            }
        }
        if (action.equals("CreateGroup")) {
            String name = request.getParameter("name");
            Long parent = Long.parseLong(request.getParameter("parent"));
            finances.createGroup(name, parent, userId);
        }
        if (action.equals("SetParent")) {
            Long item = Long.parseLong(request.getParameter("item"));
            Long parent = Long.parseLong(request.getParameter("parent"));
            finances.associate(item, parent, userId);
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

            finances.addInstantTransfer(name, amount, at, parent, userId);
        }
        if (action.equals("CreateMonthlyTransfer")) {
            String name = request.getParameter("name");
            long amount = Long.parseLong(request.getParameter("amount"));
            YearMonth begin = YearMonth.parse(request.getParameter("begin"), Formats.YEAR_MONTH);
            YearMonth end = YearMonth.parse(request.getParameter("end"), Formats.YEAR_MONTH);
            Long parent = Long.parseLong(request.getParameter("parent"));

            finances.addMonthlyTransfer(name, amount, begin, end, parent, userId);
        }
        response.sendRedirect(request.getHeader("Referer"));
        return;
    }
    Collection<Group> groups = finances.loadGroups(userId);
    Collection<YearMonth> futureMonths = new TreeSet<>();
    for (int i = 0; i < 24; i ++) {
        futureMonths.add(YearMonth.now().plusMonths(i + 1));
    }


    LocalDate today = LocalDate.now();

    Collection<YearMonth> range = root.calculateRange();
    Collection<Year> years = new TreeSet<>();
    for (YearMonth month: range) {
        years.add(Year.of(month.getYear()));
    }

    Collection<Year> yearsToShow = new TreeSet<>();
    Collection<Long> names = new TreeSet<>();
    boolean exploreFromSession = "true".equals(request.getParameter("exploreFromSession"));
    String[] itemParams;
    String[] yearParams;
    if (exploreFromSession) {
        itemParams = (String[]) session.getAttribute("explore");
        yearParams = (String[]) session.getAttribute("year");
    } else {
        itemParams = request.getParameterValues("explore");
        yearParams = request.getParameterValues("year");
        session.setAttribute("explore", itemParams);
        session.setAttribute("year", yearParams);
    }
    if (itemParams != null) {
        for (String param: itemParams) {
            names.add(Long.parseLong(param));
        }
    }
    if (yearParams != null) {
        for (String param: yearParams) {
            yearsToShow.add(Year.parse(param));
        }
    }

    names.add(focusedItemId);



    int rootDepth = root.getPath().size();

    %>
<div style="clear: left;">

    <div>
        <% for (Year year: years) {
            %> <a <%if (yearsToShow.contains(year)) {%> style="font-weight: bold" <%} else {%> style="color: #ccc;" <%}%>
                    href="summary.jsp?<%=createParams(request, year, null, focusedItemId)%>"><%=year%></a> <%
        }%>

    </div>
    <%
        {
            List<Item> path = new ArrayList<>(root.getPath());
            Collections.reverse(path);
            for (Item item: path) {
                %> <a href="summary.jsp?<%=createParams(request, null, null, item.getItemId())%>"><%= item.getName()%></a> / <%
            }
        }
    %>
    <%
if (root instanceof Group) {
    List<? extends Item> items = ((Group)root).explore(names);

    int maxDepth = 0;
    for (Item item: items) {
        maxDepth = Math.max(maxDepth, item.getPath().size() - rootDepth);
    }
    %> <table> <%
    %><tr></tr> <%
    %> <tr><th colspan="<%=maxDepth + 1%>"></th><%
    for (Year year: yearsToShow) {
        for (Month month: Month.values()) {
            boolean currentMonth = today.getYear() == year.getValue() && today.getMonth() == month;
            %> <th class="month<% if (currentMonth) {%> current-month<%}%>"><%=month.getDisplayName(TextStyle.FULL_STANDALONE, request.getLocale())%></th> <%
        }
        %> <th class="year"><%=year%></th> <%
    }
    %></tr><%
    if (root.getItemId() == 0) {

        NavigableMap<YearMonth, Balance> balances = correction.getActualBalances((Long) session.getAttribute("userId"));
        long balance;
        if (balances.isEmpty()) {
            balance = 0;
        } else {
            balance = balances.firstEntry().getValue().getAmount();
        }
        %> <tr><th class="balance balance_actual" colspan="<%=maxDepth + 1%>"><span><%=formatNumber(balance)%></span><a href="actual_balance.jsp"><img src="configure.png"/></a> </th><%
            for (Year year: yearsToShow) {
                for (Month month: Month.values()) {
                    boolean currentMonth = today.getYear() == year.getValue() && today.getMonth() == month;
                    long amount = 0;
                    for (AmountType amountType: AmountType.values()) {
                        amount += root.calculateAmount(YearMonth.of(year.getValue(), month), amountType);
                    }
                    balance += amount;
                    boolean actual = balances.containsKey(YearMonth.of(year.getValue(), month));
                    %> <th class="balance<%if (actual) {%> balance_actual<%}%><% if (currentMonth) {%> current-month<%}%>"><%= formatNumber(balance)%></th> <%
                }
                %> <th class="balance annual"><%=formatNumber(balance)%></th> <%
            }
        %></tr><%
    }
    Item last = null;
    for (int i = 0; i < items.size(); i ++) {
        Item item = items.get(i);
        %> <tr class="<%=i % 2 == 0 ? "odd" : "even"%>"><%

        if (last != null && last == item.getParent()) {

            int n = 0;
            for (int j = i; j < items.size() && items.get(j).getPath().size() >= item.getPath().size(); j ++) {
                n ++;
            }

            %> <td rowspan="<%=n%>"></td> <%
        }
        %><td colspan="<%=maxDepth-(item.getPath().size() - rootDepth) + 1%>">
            <%

                if (item instanceof Group && item.getItemId() != focusedItemId) {
                    %><a class="img" href="summary.jsp?<%=createParams(request, null, item.getItemId(), focusedItemId)%>">
                        <%
                            if (names.contains(item.getItemId())) {
                                %><img src="shrink.png"/><%
                            } else {
                                %><img src="expand.png"/><%
                            }
                        %>

                    </a><%
                } else {
                    %><a href="javascript:;"><img src="blank.png"/></a> <%
                }
                if (false && item.getParentItemId() == null) {
                    %><%=item.getName()%><%
                } else {
                    %> <a href="summary.jsp?<%=createParams(request, null, null, item.getItemId())%>"><%=item.getName()%></a> <%
                }

            %>



        </td> <%

        for (Year year: yearsToShow) {
            long annual = 0;
            Set<AmountType> annualAmountTypes = EnumSet.noneOf(AmountType.class);
            for (Month month: Month.values()) {
                boolean currentMonth = today.getYear() == year.getValue() && today.getMonth() == month;
                Set<AmountType> amountTypes = EnumSet.noneOf(AmountType.class);
                long amount = 0;
                for (AmountType amountType: AmountType.values()) {
                    long n = item.calculateAmount(YearMonth.of(year.getValue(), month), amountType);
                    if (n != 0) {
                        amount += n;
                        amountTypes.add(amountType);
                        annualAmountTypes.add(amountType);
                    }
                }
                %><td class="amount<% if (amount > 0) {%> positive<%}%> <%=getClassByAmountTypes(amountTypes)%><% if (currentMonth) {%> current-month<%}%>"><%=formatNumber(amount)%></td><%
                annual += amount;
            }
            %> <th class="annual <%=getClassByAmountTypes(annualAmountTypes)%>"><%=formatNumber(annual)%></th> <%
        }
        %></tr><%
        last = item;
    }
    %> </table> <%
    }
%>
</div>

<%

    if (root.getItemId() != 0L) {
        %>
        <div class="editor">
            <h4>Edit Attributes</h4>
            <form method="post">
                <input type="hidden" name="transferId" value="<%=root.getItemId()%>">
                <input type="hidden" name="action" value="ModifyItem">
                <label>
                    Name
                    <input name="name" size="<%=root.getName().length() + 10%>" value="<%=Escaping.safeHtml(root.getName())%>"/>
                </label>
                <br/>
                <%
                    if (root instanceof InstantTransfer) {
                %>
                <label>
                    At (<%= Formats.DATE_TIME_PATTERN %>)
                    <input name="at" value="<%= ((InstantTransfer)root).getAt().format(Formats.DATE_TIME)%>"/>
                </label>
                <br/>
                <label>
                    Amount
                    <input name="amount" value="<%=((InstantTransfer)root).getAmount()%>"/>
                </label>
                <br/>
                <%
                } else if (root instanceof MonthlyPlannedTransfer) {
                %>
                <label>
                    Begin (<%= Formats.YEAR_MONTH_PATTERN %>)
                    <input name="begin" value="<%= ((MonthlyPlannedTransfer)root).getBegin().format(Formats.YEAR_MONTH)%>"/>
                </label>
                <br/>
                <label>
                    End (<%= Formats.YEAR_MONTH_PATTERN %>)
                    <input name="end" value="<%= ((MonthlyPlannedTransfer)root).getEnd().format(Formats.YEAR_MONTH)%>"/>
                </label>
                <br/>
                <label>
                    Amount
                    <input name="amount" value="<%=((MonthlyPlannedTransfer)root).getAmount()%>"/>
                </label>
                <br/>
                <%
                    }
                %>
                <label>
                    Parent
                    <select name="parent" size="20">
                        <%
                            for (Group group : groups) {
                        %> <option <%if (Objects.equals(group.getItemId(), root.getParentItemId())) {%> selected="selected" <%}%> value="<%=group.getItemId()%>"><%=Escaping.safeHtml(getTreeFriendlyPath(group))%></option> <%
                        }
                    %>
                    </select>
                </label>
                <br/>
                <input type="submit" value="Save"/>
            </form>
        </div>
        <%
    }
%>

<%
    if (root instanceof Group) {
        %>

        <div class="editor">
            <h4>Add Instant Transfer</h4>
            <form method="post">
                <input type="hidden" name="action" value="CreateInstantTransfer"/>
                <input type="hidden" name="parent" value="<%=root.getItemId()%>"/>
                <label>
                    Name
                    <input name="name"/>
                </label>
                <label>
                    Amount
                    <input name="amount"/>
                </label>
                <label>
                    At (yyyy-MM-dd)
                    <input name="at" value="<%=Formats.DATE_TIME.format(LocalDate.now(ZoneId.of("Europe/Moscow")))%>"/>
                </label>
                <input type="submit" value="Add"/>
            </form>
        </div>

        <div class="editor">
            <h4>Add Monthly transfer</h4>
            <form method="post">
                <input type="hidden" name="action" value="CreateMonthlyTransfer"/>
                <input type="hidden" name="parent" value="<%=root.getItemId()%>"/>
                <label>
                    Name
                    <input name="name"/>
                </label>
                <label>
                    Amount
                    <input name="amount"/>
                </label>
                <label>
                    Begin (yyyy-MM)
                    <select name="begin" >
                        <%
                            for (YearMonth month: futureMonths) {
                        %><option><%=month.format(Formats.YEAR_MONTH)%></option> <%
                        }
                    %>
                    </select>
                </label>
                <label>
                    End (yyyy-MM)
                    <select name="end">
                        <%
                            for (YearMonth month: futureMonths) {
                        %><option><%=month.format(Formats.YEAR_MONTH)%></option> <%
                        }
                    %>
                    </select>
                </label>
                <input type="submit" value="Add"/>
            </form>
        </div>

        <div class="editor">
            <h4>Add New Group</h4>
            <form method="post">
                <input type="hidden" name="action" value="CreateGroup"/>
                <input type="hidden" name="parent" value="<%=root.getItemId()%>"/>
                <label>
                    Name
                    <input name="name"/>
                </label>
                <input type="submit" value="Add"/>
            </form>
        </div>
        <%
    }
    if (root.getItemId() != 0L) {
        %>
        <div class="editor">
            <h4>Delete item</h4>
            <form method="post" action="delete.jsp">
                <input type="hidden" name="transferId" value="<%=root.getItemId()%>">
                <input type="hidden" name="referrer" value="<%=Escaping.safeHtml(request.getContextPath()+request.getServletPath()+"?"+request.getQueryString())%>"/>
                <input type="hidden" name="parentPage" value="<%=Escaping.safeHtml(request.getContextPath()+request.getServletPath()+"?"+createParams(request, null, null, root.getParentItemId()))%>"/>
                <input type="submit" value="Delete"/>
            </form>
        </div>
        <%
    }
%>

</body>
</html>
