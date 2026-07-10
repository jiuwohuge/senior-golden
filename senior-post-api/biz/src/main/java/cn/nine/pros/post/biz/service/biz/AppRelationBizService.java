package cn.nine.pros.post.biz.service.biz;

import cn.nine.pros.post.client.model.input.app.CreatePenpalRequestInDto;
import cn.nine.pros.post.client.model.out.PenpalRequestResultVO;
import cn.nine.pros.post.client.model.out.PostOfficeRelationMessageVO;
import cn.nine.pros.post.client.model.out.RelationSnapshotVO;

import java.util.List;

/**
 * §10 关系业务：展示态推导、笔友申请与邮局关系消息。
 */
public interface AppRelationBizService {

    RelationSnapshotVO resolveRelationSnapshot(long viewerUserId, long peerUserId);

    PenpalRequestResultVO createPenpalRequest(long actorUserId, CreatePenpalRequestInDto body);

    PenpalRequestResultVO createPenpalRequestFromLetter(long actorUserId, long letterId);

    PenpalRequestResultVO acceptPenpalRequest(long actorUserId, long requestId);

    PenpalRequestResultVO ignorePenpalRequest(long actorUserId, long requestId);

    List<PostOfficeRelationMessageVO> listRelationMessages(long viewerUserId);

    int countRelationMessages(long viewerUserId);
}
