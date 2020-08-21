package com.roxic.crm.workbench.dao;

import com.roxic.crm.workbench.domain.ContactsRemark;

import java.util.List;

public interface ContactsRemarkDao {

    int save(ContactsRemark contactsRemark);

    int getCountsByConids(String[] ids);

    int deleteByConids(String[] ids);

    int updateRemark(ContactsRemark conr);

    List<ContactsRemark> getRemarkListByConid(String contactsId);

    int removeRemark(String id);

    int saveRemark(ContactsRemark conr);
}
