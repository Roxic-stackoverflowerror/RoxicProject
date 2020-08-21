package com.roxic.crm.workbench.service;

import com.roxic.crm.vo.PageListVO;
import com.roxic.crm.workbench.domain.Contacts;
import com.roxic.crm.workbench.domain.ContactsRemark;
import com.roxic.crm.workbench.domain.Tran;

import java.util.List;
import java.util.Map;

public interface ContactsService {
    List<Contacts> getContactsListByName(Map<String, String> map);

    boolean saveContacts(Contacts contacts);

    boolean delete(String[] ids);

    PageListVO<Contacts> pageList(Map<String, Object> map);

    boolean save(Contacts contacts,String customerName);

    boolean update(Contacts contacts);

    Map<String, Object> getUserListAndContacts(String id);

    Contacts detail(String id);

    boolean updateRemark(ContactsRemark conr);

    List<ContactsRemark> getRemarkListByConid(String contactsId);

    boolean removeRemark(String id);

    boolean saveRemark(ContactsRemark conr);

    boolean bound(String contactsId, String[] activityIds);

    boolean unbound(String id);

    List<Tran> getTranListByConid(String id);
}
