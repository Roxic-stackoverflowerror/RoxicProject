package com.roxic.crm.workbench.service;

import com.roxic.crm.vo.PageListVO;
import com.roxic.crm.workbench.domain.Contacts;
import com.roxic.crm.workbench.domain.Customer;
import com.roxic.crm.workbench.domain.CustomerRemark;
import com.roxic.crm.workbench.domain.Tran;

import java.util.List;
import java.util.Map;

public interface CustomerService {
    List<String> getCustomerName(String name);

    PageListVO<Customer> pageList(Map<String, Object> map);

    boolean save(Customer customer);

    boolean update(Customer customer);

    Map<String, Object> getUserListAndCustomer(String id);

    boolean delete(String[] ids);

    Customer detail(String id);

    boolean updateRemark(CustomerRemark cur);

    List<CustomerRemark> getRemarkListByCuid(String customerId);

    boolean removeRemark(String id);

    boolean saveRemark(CustomerRemark cur);

    List<Tran> getTranListByCuid(String id);

    List<Contacts> getContactsListByCuid(String id);
}
