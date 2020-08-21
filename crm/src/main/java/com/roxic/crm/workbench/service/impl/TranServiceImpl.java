package com.roxic.crm.workbench.service.impl;

import com.roxic.crm.utils.DateTimeUtil;
import com.roxic.crm.utils.SqlSessionUtil;
import com.roxic.crm.utils.UUIDUtil;
import com.roxic.crm.vo.PageListVO;
import com.roxic.crm.workbench.dao.ContactsDao;
import com.roxic.crm.workbench.dao.CustomerDao;
import com.roxic.crm.workbench.dao.TranDao;
import com.roxic.crm.workbench.dao.TranHistoryDao;
import com.roxic.crm.workbench.domain.Contacts;
import com.roxic.crm.workbench.domain.Customer;
import com.roxic.crm.workbench.domain.Tran;
import com.roxic.crm.workbench.domain.TranHistory;
import com.roxic.crm.workbench.service.TranService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TranServiceImpl implements TranService {
    private TranDao tranDao = SqlSessionUtil.getSqlSession().getMapper(TranDao.class);
    private TranHistoryDao tranHistoryDao = SqlSessionUtil.getSqlSession().getMapper(TranHistoryDao.class);
    private CustomerDao customerDao = SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);

    @Override
    public PageListVO<Tran> pageList(Map<String, Object> map) {
        Integer total = tranDao.getTotalByCondition(map);

        //取得dataList
        List<Tran> dataList = tranDao.getTranListByCondition(map);

        //创建vo，打包
        PageListVO<Tran> vo = new PageListVO<Tran> ();
        vo.setTotal(total);
        vo.setDataList(dataList);

        //返回
        return vo;
    }

    @Override
    public boolean save(Tran tran, String customerName) {
        /*
            交易添加业务：

                在做添加之前，参数tran里面就少了一项信息，就是客户的主键，customerId
                先处理客户相关的需求

                （1）判断customerName，根据客户名称在客户表进行精确查询
                       如果有这个客户，则取出这个客户的id，封装到tran对象中
                       如果没有这个客户，则再客户表新建一条客户信息，然后将新建的客户的id取出，封装到tran对象中

                （2）经过以上操作后，tran对象中的信息就全了，需要执行添加交易的操作

                （3）添加交易完毕后，需要创建一条交易历史
         */

        boolean flag = true;

        Customer customer = customerDao.getCustomerByName(customerName);

        //如果cus为null，需要创建客户
        if(customer==null){

            customer = new Customer();
            customer.setId(UUIDUtil.getUUID());
            customer.setName(customerName);
            customer.setCreateBy(tran.getCreateBy());
            customer.setCreateTime(DateTimeUtil.getSysTime());
            customer.setContactSummary(tran.getContactSummary());
            customer.setNextContactTime(tran.getNextContactTime());
            customer.setOwner(tran.getOwner());
            //添加客户
            int count1 = customerDao.save(customer);
            if(count1!=1){
                flag = false;
            }

        }

        //通过以上对于客户的处理，不论是查询出来已有的客户，还是以前没有我们新增的客户，总之客户已经有了，客户的id就有了
        //将客户id封装到t对象中
        tran.setCustomerId(customer.getId());

        //添加交易
        int count2 = tranDao.save(tran);
        if(count2!=1){
            flag = false;
        }

        //添加交易历史
        TranHistory tranHistory = new TranHistory();
        tranHistory.setId(UUIDUtil.getUUID());
        tranHistory.setTranId(tran.getId());
        tranHistory.setStage(tran.getStage());
        tranHistory.setMoney(tran.getMoney());
        tranHistory.setExpectedDate(tran.getExpectedDate());
        tranHistory.setCreateTime(DateTimeUtil.getSysTime());
        tranHistory.setCreateBy(tran.getCreateBy());
        int count3 = tranHistoryDao.save(tranHistory);
        if(count3!=1){
            flag = false;
        }

        return flag;
    }

    @Override
    public Tran detail(String id) {
        Tran tran = tranDao.detail(id);
        return tran;
    }

    @Override
    public List<TranHistory> getHistoryListByTranId(String tranId) {
        List<TranHistory> thList = tranHistoryDao.getHistoryListByTranId(tranId);

        return thList;
    }

    @Override
    public boolean changeStage(Tran tran) {
        boolean flag = true;
        //改变交易阶段
        int count1 = tranDao.changeStage(tran);
        if(count1 != 1){
            flag = false;
        }
        //改变后，生成一条交易历史
        TranHistory tranHistory = new TranHistory();
        tranHistory.setId(UUIDUtil.getUUID());
        tranHistory.setCreateBy(tran.getEditBy());
        tranHistory.setCreateTime(DateTimeUtil.getSysTime());
        tranHistory.setExpectedDate(tran.getExpectedDate());
        tranHistory.setMoney(tran.getMoney());
        tranHistory.setTranId(tran.getId());
        tranHistory.setStage(tran.getStage());
        //添加交易历史
        int count2 = tranHistoryDao.save(tranHistory);
        if(count2 != 1){
            flag = false;
        }

        return flag;
    }

    @Override
    public Map<String, Object> getCharts() {
        //取得total
        int total = tranDao.getTotal();
        //取得datalist
        List<Map<String,Object>> dataList = tranDao.getCharts();
        //打包
        Map<String, Object> map = new HashMap<String,Object>();
        map.put("total",total);
        map.put("dataList",dataList);

        return map;
    }

    @Override
    public boolean remove(String id) {
        boolean flag = true;
        int count = tranDao.remove(id);
        if(count != 1){
            flag = false;
        }
        return flag;
    }

    @Override
    public boolean delete(String[] ids) {
        boolean flag = true;


        int count1 = tranHistoryDao.getCountsByTids(ids);

        int count2 = tranHistoryDao.deleteByTids(ids);


        if(count1 != count2){
            flag = false;
        }

        int count3 = tranDao.delete(ids);
        if(count3 != ids.length){
            flag = false;
        }
        return flag;
    }

    @Override
    public Tran getTranById(String id) {
        Tran tran = tranDao.getTranById(id);
        return tran;
    }

    @Override
    public boolean update(Tran tran) {
        boolean flag = true;
        int count = tranDao.update(tran);
        if (count != 1){
            flag = false;
        }
        return flag;
    }
}
