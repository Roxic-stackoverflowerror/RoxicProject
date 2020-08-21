package com.roxic.crm.workbench.dao;

import com.roxic.crm.workbench.domain.ClueActivityRelation;

import java.util.List;

public interface ClueActivityRelationDao {



    int unbound(String id);

    int bound(ClueActivityRelation clueActivityRelation);

    List<ClueActivityRelation> getListByClueId(String clueId);

    int delete(ClueActivityRelation clueActivityRelation);

    int deletByCids(String[] ids);

    int getCountsByCids(String[] ids);
}
