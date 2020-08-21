package com.roxic.crm.workbench.dao;

import com.roxic.crm.workbench.domain.Customer;

import java.util.List;
import java.util.Map;

public interface CustomerDao {

    Customer getCustomerByName(String company);

    int save(Customer customer);

    List<String> getCustomerName(String name);

    List<Customer> getCustomerListByCondition(Map<String, Object> map);

    Integer getTotalByCondition(Map<String, Object> map);

    int update(Customer customer);

    Customer getCustomerById(String id);

    int delete(String[] ids);

    Customer detail(String id);
}
