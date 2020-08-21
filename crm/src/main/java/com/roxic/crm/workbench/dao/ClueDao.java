package com.roxic.crm.workbench.dao;

import com.roxic.crm.workbench.domain.Clue;

import java.util.List;
import java.util.Map;

public interface ClueDao {


    int save(Clue clue);

    Integer getTotalByCondition(Map<String, Object> map);

    List<Clue> getClueListByCondition(Map<String, Object> map);

    int delete(String[] ids);

    Clue detail(String id);

    Clue getById(String clueId);

    int deleteById(String clueId);

    Clue getClueById(String id);

    int update(Clue clue);
}
