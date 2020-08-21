package com.roxic.crm.workbench.dao;

import com.roxic.crm.workbench.domain.CustomerRemark;

import java.util.List;

public interface CustomerRemarkDao {

    int save(CustomerRemark customerRemark);

    int getCountsByCuids(String[] ids);

    int deleteByCuids(String[] ids);

    int updateRemark(CustomerRemark cur);

    List<CustomerRemark> getRemarkListByCuid(String customerId);

    int removeRemark(String id);

    int saveRemark(CustomerRemark cur);
}
