package cn.nine.pros.post.senior_post_flutter

import io.flutter.embedding.android.FlutterFragmentActivity

/// 使用 FragmentActivity 宿主，利于 Activity 生命周期与部分插件（image_picker / Photo Picker 等）稳定注册 Pigeon。
class MainActivity : FlutterFragmentActivity()
