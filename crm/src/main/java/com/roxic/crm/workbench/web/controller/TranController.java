package com.roxic.crm.workbench.web.controller;


import com.roxic.crm.settings.domain.User;
import com.roxic.crm.settings.service.Impl.UserServiceImpl;
import com.roxic.crm.settings.service.UserService;
import com.roxic.crm.utils.DateTimeUtil;
import com.roxic.crm.utils.PrintJson;
import com.roxic.crm.utils.ServiceFactory;
import com.roxic.crm.utils.UUIDUtil;
import com.roxic.crm.vo.PageListVO;
import com.roxic.crm.workbench.domain.Contacts;
import com.roxic.crm.workbench.domain.Tran;
import com.roxic.crm.workbench.domain.TranHistory;
import com.roxic.crm.workbench.service.ContactsService;
import com.roxic.crm.workbench.service.CustomerService;
import com.roxic.crm.workbench.service.TranService;
import com.roxic.crm.workbench.service.impl.ContactsServiceImpl;
import com.roxic.crm.workbench.service.impl.CustomerServiceImpl;
import com.roxic.crm.workbench.service.impl.TranServiceImpl;


import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TranController extends HttpServlet {
    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        System.out.println("进入到交易控制器");

        String path = request.getServletPath();

        if ("/workbench/transaction/add.do".equals(path)) {
            add(request, response);

        } else if ("/workbench/transaction/getContactsListByName.do".equals(path)) {

            getContactsListByName(request, response);

        }else if ("/workbench/transaction/getCustomerName.do".equals(path)) {

            getCustomerName(request, response);

        }else if ("/workbench/transaction/pageList.do".equals(path)) {

            pageList(request, response);

        }else if ("/workbench/transaction/save.do".equals(path)) {

            save(request, response);

        }else if ("/workbench/transaction/detail.do".equals(path)) {

            detail(request, response);

        }else if ("/workbench/transaction/getHistoryListByTranId.do".equals(path)) {

            getHistoryListByTranId(request, response);

        } else if ("/workbench/transaction/changeStage.do".equals(path)) {

            changeStage(request, response);

        }else if ("/workbench/transaction/getCharts.do".equals(path)) {

            getCharts(request, response);

        }else if ("/workbench/transaction/remove.do".equals(path)) {

            remove(request, response);

        }else if ("/workbench/transaction/edit.do".equals(path)) {

            edit(request, response);

        }else if ("/workbench/transaction/delete.do".equals(path)) {

            delete(request, response);

        }else if ("/workbench/transaction/update.do".equals(path)) {

            update(request, response);

        }else if ("/workbench/transaction/xxx.do".equals(path)) {

            //xxx(request, response);

        }
    }

    private void update(HttpServletRequest request, HttpServletResponse response) throws IOException {
        System.out.println("提交了修改交易的操作");
        String id = request.getParameter("id");
        String owner = request.getParameter("owner");
        String money = request.getParameter("money");
        String name = request.getParameter("name");
        String expectedDate = request.getParameter("expectedDate");
        String customerId = request.getParameter("customerId"); //此处我们暂时只有客户名称，还没有id
        String stage = request.getParameter("stage");
        String type = request.getParameter("type");
        String source = request.getParameter("source");
        String activityId = request.getParameter("activityId");
        String contactsId = request.getParameter("contactsId");
        String editTime = DateTimeUtil.getSysTime();
        String editBy = ((User)request.getSession().getAttribute("user")).getName();
        String description = request.getParameter("description");
        String contactSummary = request.getParameter("contactSummary");
        String nextContactTime = request.getParameter("nextContactTime");

        Tran tran = new Tran();
        tran.setId(id);
        tran.setOwner(owner);
        tran.setMoney(money);
        tran.setName(name);
        tran.setExpectedDate(expectedDate);
        tran.setStage(stage);
        tran.setType(type);
        tran.setSource(source);
        tran.setActivityId(activityId);
        tran.setContactsId(contactsId);
        tran.setEditTime(editTime);
        tran.setEditBy(editBy);
        tran.setDescription(description);
        tran.setContactSummary(contactSummary);
        tran.setNextContactTime(nextContactTime);
        tran.setCustomerId(customerId);

        TranService tranService = (TranService) ServiceFactory.getService(new TranServiceImpl());

        boolean flag = tranService.update(tran);

        if(flag){

            //如果添加交易成功，跳转到列表页
            //这里应该使用重定向，而不是请求转发，因为request域不传值，没必要，而且会请求转发会留在老路径上，路径会变成save.do/.............
            response.sendRedirect(request.getContextPath() + "/workbench/transaction/detail.do?id="+id);

        }
    }

    private void edit(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("进入修改交易的页面");
        String id = request.getParameter("id");
        TranService tranService = (TranService) ServiceFactory.getService(new TranServiceImpl());
        Tran tran = tranService.getTranById(id);
        request.setAttribute("tran",tran);
        request.getRequestDispatcher("/workbench/transaction/edit.jsp").forward(request,response);
    }

    private void delete(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("执行交易删除操作");
        String[] ids = request.getParameterValues("id");
        TranService tranService = (TranService) ServiceFactory.getService(new TranServiceImpl());
        boolean flag = tranService.delete(ids);
        PrintJson.printJsonFlag(response,flag);
    }

    private void remove(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("在客户详细页删除交易");
        String id = request.getParameter("tranId");
        TranService tranService = (TranService) ServiceFactory.getService(new TranServiceImpl());
        boolean flag = tranService.remove(id);
        PrintJson.printJsonFlag(response,flag);

    }

    private void getCharts(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("取得交易阶段数量统计图表数据");
        TranService tranService = (TranService) ServiceFactory.getService(new TranServiceImpl());
        Map<String,Object> map = tranService.getCharts();
        PrintJson.printJsonObj(response,map);
    }

    private void changeStage(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("交易详细页中的阶段变更操作");
        String tranId = request.getParameter("tranId");
        String stage = request.getParameter("stage");
        String money = request.getParameter("money");
        String expectedDate = request.getParameter("expectedDate");
        String editTime = DateTimeUtil.getSysTime();
        String editBy = ((User) request.getSession().getAttribute("user")).getName();
        Tran tran = new Tran();
        tran.setId(tranId);
        tran.setStage(stage);
        tran.setMoney(money);
        tran.setEditTime(editTime);
        tran.setExpectedDate(expectedDate);
        tran.setEditBy(editBy);
        TranService tranService = (TranService) ServiceFactory.getService(new TranServiceImpl());
        boolean flag = tranService.changeStage(tran);
        Map<String,String> possibilityMap = (Map<String,String>)this.getServletContext().getAttribute("possibilityMap");
        tran.setPossibility(possibilityMap.get(stage));
        Map<String,Object> map = new HashMap<String, Object> ();
        map.put("success",flag);
        map.put("tran",tran);
        PrintJson.printJsonObj(response,map);

    }

    private void getHistoryListByTranId(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("根据交易id取得相应的历史列表");

        String tranId = request.getParameter("tranId");

        TranService tranService = (TranService) ServiceFactory.getService(new TranServiceImpl());

        List<TranHistory> tranHistoryList= tranService.getHistoryListByTranId(tranId);

        //阶段和可能性之间的对应关系
        Map<String,String> possibilityMap = (Map<String,String>)this.getServletContext().getAttribute("possibilityMap");

        //将交易历史列表遍历
        for(TranHistory tranHistory : tranHistoryList){

            //根据每条交易历史，取出每一个阶段
            String stage = tranHistory.getStage();
            String possibility = possibilityMap.get(stage);
            tranHistory.setPossibility(possibility);

        }


        PrintJson.printJsonObj(response, tranHistoryList);
    }

    private void detail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("跳转到交易详细页");
        String id = request.getParameter("id");
        TranService tranService = (TranService) ServiceFactory.getService(new TranServiceImpl());

        Tran tran = tranService.detail(id);

        //处理可能性
        /*
            阶段 tran
            阶段和可能性之间的对应关系 possibilityMap
         */

        String stage = tran.getStage();
        Map<String,String> possibilityMap = (Map<String,String>)this.getServletContext().getAttribute("possibilityMap");
        String possibility = possibilityMap.get(stage);


        tran.setPossibility(possibility);

        request.setAttribute("tran", tran);
        request.getRequestDispatcher("/workbench/transaction/detail.jsp").forward(request, response);

    }

    private void save(HttpServletRequest request, HttpServletResponse response) throws IOException {

        System.out.println("执行添加交易的操作");
        String id = UUIDUtil.getUUID();
        String owner = request.getParameter("owner");
        String money = request.getParameter("money");
        String name = request.getParameter("name");
        String expectedDate = request.getParameter("expectedDate");
        String customerName = request.getParameter("customerName"); //此处我们暂时只有客户名称，还没有id
        String stage = request.getParameter("stage");
        String type = request.getParameter("type");
        String source = request.getParameter("source");
        String activityId = request.getParameter("activityId");
        String contactsId = request.getParameter("contactsId");
        String createTime = DateTimeUtil.getSysTime();
        String createBy = ((User)request.getSession().getAttribute("user")).getName();
        String description = request.getParameter("description");
        String contactSummary = request.getParameter("contactSummary");
        String nextContactTime = request.getParameter("nextContactTime");

        Tran tran = new Tran();
        tran.setId(id);
        tran.setOwner(owner);
        tran.setMoney(money);
        tran.setName(name);
        tran.setExpectedDate(expectedDate);
        tran.setStage(stage);
        tran.setType(type);
        tran.setSource(source);
        tran.setActivityId(activityId);
        tran.setContactsId(contactsId);
        tran.setCreateTime(createTime);
        tran.setCreateBy(createBy);
        tran.setDescription(description);
        tran.setContactSummary(contactSummary);
        tran.setNextContactTime(nextContactTime);

        TranService tranService = (TranService) ServiceFactory.getService(new TranServiceImpl());

        boolean flag = tranService.save(tran,customerName);

        if(flag){

            //如果添加交易成功，跳转到列表页
            //这里应该使用重定向，而不是请求转发，因为request域不传值，没必要，而且会请求转发会留在老路径上，路径会变成save.do/.............
            response.sendRedirect(request.getContextPath() + "/workbench/transaction/index.jsp");

        }
    }

    private void pageList(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("展示交易列表的操作执行了");
        String owner = request.getParameter("owner");
        String name = request.getParameter("name");
        String customer = request.getParameter("customer");
        String stage = request.getParameter("stage");
        String type = request.getParameter("type");
        String source = request.getParameter("source");
        String contacts = request.getParameter("contacts");
        String pageNoStr =request.getParameter("pageNo");
        String pageSizeStr =request.getParameter("pageSize");

        int pageNo = Integer.valueOf(pageNoStr);
        int pageSize = Integer.valueOf(pageSizeStr);
        //LIMIT x,y 略过x条，查y条。
        //计算出略过的记录数
        int skipCount = (pageNo - 1) * pageSize;
        //打包
        Map<String,Object> map = new HashMap<String, Object>();
        map.put("owner",owner);
        map.put("name",name);
        map.put("customer",customer);
        map.put("stage",stage);
        map.put("type",type);
        map.put("source",source);
        map.put("contacts",contacts);
        map.put("skipCount",skipCount);
        map.put("pageSize",pageSize);

        TranService tranService = (TranService) ServiceFactory.getService(new TranServiceImpl());

        PageListVO<Tran> vo = tranService.pageList(map);
        PrintJson.printJsonObj(response,vo);
    }

    private void getCustomerName(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("开始自动补全操作，取得客户列表");
        String name = request.getParameter("name");
        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        List<String> sList = customerService.getCustomerName(name);
        PrintJson.printJsonObj(response,sList);
    }

    private void getContactsListByName(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入查询联系人的操作");
        String contactsName = request.getParameter("contactsName");
        String company = request.getParameter("company");
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        Map<String, String> map = new HashMap<String, String>();
        map.put("contactsName",contactsName);
        map.put("company",company);
        List<Contacts> contactsList = contactsService.getContactsListByName(map);
        PrintJson.printJsonObj(response,contactsList);
    }

    private void add(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("进入添加交易的页面");
        String name = request.getParameter("name");
        UserService userService = (UserService) ServiceFactory.getService(new UserServiceImpl());
        List<User> userList = userService.getUserList();
        //Map<String,Object> map = new HashMap<String, Object> ();
        //map.put("name",name);
        //map.put("userList",userList);
        request.setAttribute("name",name);
        request.setAttribute("userList",userList);
        //request.setAttribute("map",map);
        request.getRequestDispatcher("/workbench/transaction/save.jsp").forward(request,response);
    }
}
