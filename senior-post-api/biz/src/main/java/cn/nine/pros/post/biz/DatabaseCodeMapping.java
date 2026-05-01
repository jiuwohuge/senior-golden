package cn.nine.pros.post.biz;

import cn.nine.commons.feign.bridge.core.config.dbs.DbHandlerProxy;
import cn.nine.commons.feign.bridge.core.config.dbs.DbHandlerService;
import cn.nine.commons.feign.bridge.core.config.enums.DbTypeEnum;
import cn.nine.commons.feign.bridge.core.config.utils.DbUtils;
import cn.nine.commons.feign.bridge.core.model.constant.TemplateConstant;
import cn.nine.commons.feign.bridge.core.model.constant.TemplatePackageConstant;
import cn.nine.commons.feign.bridge.core.model.dbs.ColumnDto;
import cn.nine.commons.feign.bridge.core.model.dbs.TableDto;
import cn.nine.commons.feign.bridge.core.model.java.CodeConfig;
import cn.nine.commons.feign.bridge.core.model.java.TemplateInfo;
import cn.nine.commons.feign.bridge.core.utils.OrmEngineEnum;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.velocity.Template;
import org.apache.velocity.VelocityContext;
import org.apache.velocity.app.VelocityEngine;
import org.apache.velocity.runtime.RuntimeConstants;
import org.apache.velocity.runtime.resource.loader.ClasspathResourceLoader;
import org.springframework.util.CollectionUtils;

import java.io.File;
import java.io.StringWriter;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Slf4j
public class DatabaseCodeMapping {

    /**
     * 目前仅实现了beetsql 版本
     * <p>
     * html 如果要放在其他地方，记得修改templateConstant中的module
     *
     * @param args
     * @throws Exception
     */
    public static void main(String[] args) throws Exception {
        //获取db适配器
        CodeConfig codeConfig = new CodeConfig();
        codeConfig.setOrmEngine(OrmEngineEnum.MYBATIS);
        codeConfig.setCoverFlag(false);
        codeConfig.setDbTypeEnum(DbTypeEnum.PgSql);
        codeConfig.setStandLoneFlag(false);
        codeConfig.setDataBaseName("senior_post");
        codeConfig.setTableExcludeList(Arrays.asList(
                        "bs_example"
                )
        );
        codeConfig.setProjectPackageName("cn.nine.pros.post");
        codeConfig.setPathDir("D:\\04_idea_workplace\\02_gitee\\commons-frameworkv2\\senior-post-api");
        codeConfig.setTemplateList(Arrays.asList(
                TemplatePackageConstant.domain,
                TemplatePackageConstant.dtoDb,
                TemplatePackageConstant.mapstruct,
                TemplatePackageConstant.repository,
                TemplatePackageConstant.resource,
                TemplatePackageConstant.sql,
                TemplatePackageConstant.client,
                TemplatePackageConstant.feignClient,
                TemplatePackageConstant.feignResource
//                TemplatePackageConstant.manageController,
//                TemplatePackageConstant.dtoInput,
//                TemplatePackageConstant.htmlList,
//                TemplatePackageConstant.htmlEdit
        ));
        DatabaseCodeMapping mapping = new DatabaseCodeMapping();
        mapping.parse(codeConfig);
    }

    /**
     * 转换表为预定模板
     *
     * @param codeConfig
     * @throws Exception
     */
    public void parse(CodeConfig codeConfig) throws Exception {
        List<TableDto> tableList = this.queryTableInfo(codeConfig);
        if (CollectionUtils.isEmpty(tableList)) {
            log.warn("没有找到符合条件的表");
            return;
        }
        // 删除目录
//        FileUtils.deleteDirectory(new File(codeConfig.getPathDir()));
        List<TemplateInfo> currentTemplateInfo = TemplateConstant.TEMPLATE_MAPPING.stream()
                .filter(mapping -> mapping.getOrmEngineEnum() == null
                        || mapping.getOrmEngineEnum().equals(codeConfig.getOrmEngine())).collect(Collectors.toList());

        // java对象数据传递到模板文件vm
        List<String> templateList = codeConfig.getTemplateList();
        for (TableDto tableDto : tableList) {
            for (TemplateInfo templateInfo : currentTemplateInfo) {
                String templateName = templateInfo.getTemplateName();
                if (!CollectionUtils.isEmpty(templateList) && !templateList.contains(templateName)) {
                    log.info("模板{}不在配置中，跳过", templateName);
                    continue;
                }


                String sourcePath = templateInfo.getSourcePath();
                // 初始化模板文件vm
                VelocityContext ctx = initVelocityContext(codeConfig, tableDto, templateInfo);
                //渲染并生成文件
                VelocityEngine ve = new VelocityEngine();
                ve.setProperty(RuntimeConstants.RESOURCE_LOADER, "classpath");
                ve.setProperty("classpath.resource.loader.class", ClasspathResourceLoader.class.getName());
                ve.setProperty("input.encoding", "UTF-8");
                ve.setProperty("output.encoding", "UTF-8");
                ve.init();
                Template template = ve.getTemplate(sourcePath);
                StringWriter sw = new StringWriter();
                template.merge(ctx, sw);
                String code = sw.toString();

                String filePath = installFilePath(codeConfig, templateInfo);
                String fileName = tableDto.getJavaClassName() + templateInfo.getFileName();

                filePath = filePath.replace("/", File.separator);
                if (templateInfo.getFileName().contains("html")) {
                    filePath += File.separator + tableDto.getUrlPath() + File.separator;
                    fileName = templateInfo.getFileName();
                }
                if (templateInfo.getFileName().contains("md")) {
                    fileName = tableDto.getTableName() + ".md";
                }
                fileName = fileName.replace("/", File.separator);

                File file = new File(filePath + File.separator + fileName);
                if (!file.exists()) {
                    FileUtils.write(file, code, StandardCharsets.UTF_8);
                    continue;
                }
                if (!codeConfig.isCoverFlag()) {
                    continue;
                }
                FileUtils.deleteQuietly(file);
                FileUtils.write(file, code, StandardCharsets.UTF_8);
                log.info("文件：{} 已经生成!", filePath + File.separator + fileName);
            }
        }
    }

    /**
     * 包名：packageName
     * 模块包名：modulePackageName
     * 上级自定义包名：superPackageName
     * 类注释：classComments
     * 作者：author
     * 表名：tableName
     * 首字母大写类名：upperClassName
     * 首字母小写类名：lowerClassname
     * 字段：columns【tableName，columnName，comment，primaryKey，autoIncr，javaType，javaFieldName，dataType】
     * 主键类型：primaryType
     * <p>
     * 初始化模板文件vm 设置参数
     *
     * @param codeConfig
     * @param tableDto
     * @param templateInfo
     * @return
     */
    private static VelocityContext initVelocityContext(CodeConfig codeConfig, TableDto tableDto,
                                                       TemplateInfo templateInfo) {
        VelocityContext ctx = new VelocityContext();
        List<ColumnDto> columnInfos = tableDto.getColumnDtos();
        //包名
        ctx.put("packageName", codeConfig.getProjectPackageName());
        //模块包名
        ctx.put("modulePackageName", templateInfo.getModuleName());
        //上级自定义包名
        ctx.put("superPackageName", templateInfo.getSupperPackageName());
        //类注释
        ctx.put("classComments", tableDto.getTableComment());
        //作者
        ctx.put("author", codeConfig.getAuthor());
        //表名
        ctx.put("tableName", tableDto.getTableName());
        //首字母大写类名
        ctx.put("upperClassName", tableDto.getJavaClassName());
        //首字母小写
        ctx.put("lowerTableClassName", tableDto.getJavaLowerClassName());
        //去除前缀后的表名
        ctx.put("tablePathName", tableDto.getUrlPath());
        //字段
        ctx.put("columns", columnInfos);
        if (!codeConfig.isStandLoneFlag()) {
            ctx.put("dtoSuffix", "");
            ctx.put("client", ".client");
            ctx.put("biz", ".biz");
            ctx.put("model", ".model");
        } else {
            ctx.put("dtoSuffix", ".model");
            ctx.put("client", "");
            ctx.put("biz", "");
            ctx.put("model", "");
            if (templateInfo.getSourcePath().equals("service/DTO.java.vm")) {
                templateInfo.setSupperPackageName("model.model.db");
            }
        }
        /********************其他附加信息*******************/
        Map<String, String> templatePackageMap =
                TemplateConstant.getTemplatePackageMap(codeConfig);
        templatePackageMap.forEach(ctx::put);
        //打印
        Object[] keys = ctx.getKeys();
        if (keys != null) {
            for (Object key : keys) {
                log.info("key:{},value:{}", key, ctx.get(key.toString()));
            }
        }

        Optional<ColumnDto> primaryColumn = columnInfos.stream()
                .filter(ColumnDto::getPrimaryKey).findFirst();
        String javaType = "String";
        if (primaryColumn.isPresent()) {
            javaType = primaryColumn.get().getJavaType();
        }
        //主键类型
        ctx.put("primaryType", javaType);
        return ctx;
    }

    /**
     * 查询本次生成需要的表信息
     *
     * @param codeConfig
     * @return
     * @throws Exception
     */
    private List<TableDto> queryTableInfo(CodeConfig codeConfig) throws Exception {
        DbHandlerService dbHandlerService =
                DbHandlerProxy.getHandlerObject(codeConfig);

        List<String> tableIncludeList = codeConfig.getTableIncludeList();
        List<String> tableExcludeList = codeConfig.getTableExcludeList();
        // 查询所有表的信息
        List<TableDto> tableInfo = dbHandlerService.getTableInfo();
        List<ColumnDto> columnInfo = dbHandlerService.getColumnInfo();
        List<TableDto> finalyTableList = tableInfo.stream()
                .filter(table -> {
                    //如果配置了排除表，则排除
                    if (!CollectionUtils.isEmpty(tableExcludeList) && tableExcludeList.contains(table.getTableName())) {
                        return false;
                    }
                    //如果配置了包含表，则包含
                    return CollectionUtils.isEmpty(tableIncludeList) || tableIncludeList.contains(table.getTableName());
                }).collect(Collectors.toList());
        finalyTableList.forEach(table -> {
            //设置字段
            String tableName = table.getTableName();
            List<ColumnDto> columnList = columnInfo.stream().filter(column -> column.getTableName()
                    .equals(tableName)).collect(Collectors.toList());
            table.setColumnDtos(columnList);
            //去除前缀
            String prefix = tableName.split("_")[0];
            String path = tableName.replace(prefix + "_", "");
            table.setJavaClassName(DbUtils.lineToUpperHump(path));
            table.setJavaLowerClassName(DbUtils.lineToLowerHump(path));
            table.setUrlPath(path);
        });
        return finalyTableList;
    }

    /**
     * 组装文件路径
     *
     * @param codeConfig
     * @param templateInfo
     * @return
     */
    private static String installFilePath(CodeConfig codeConfig, TemplateInfo templateInfo) {
        //项目目录
        String projectDir = codeConfig.getPathDir();
        //模块名
        String moduleName = templateInfo.getModuleName();
        //模块
        String realModuleName = moduleName + File.separator;
        if (codeConfig.isStandLoneFlag()) {
            realModuleName = "";
        }
        //资源路径
        String resourcePackage = "src" + File.separator + "main" + File.separator + "resources";
        //模块下 文件的上级目录包名
        String supperPackageName = templateInfo.getSupperPackageName();
        //文件类型
        String classType = templateInfo.getFileName().substring(templateInfo.getFileName().lastIndexOf(".") + 1);
        //java 文件路径
        String javaDir = "src" + File.separator + "main" + File.separator + "java";
        //java 包路径
        String javaPackage = codeConfig.getProjectPackageName().replace(".", File.separator);


        String result = projectDir + File.separator + realModuleName + javaDir
                + File.separator + javaPackage + (codeConfig.isStandLoneFlag() ? "" : (File.separator + moduleName));
        if (!classType.equals("java")) {
            result = projectDir + File.separator + realModuleName + File.separator + resourcePackage;
        }
        if (StringUtils.isNotBlank(supperPackageName)) {
            result += File.separator + supperPackageName.replace(".", File.separator);
        }
        return result;
    }


}
