// ignore_for_file: constant_identifier_names

part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const SPLASH = _Paths.SPLASH;
  static const HOME = _Paths.HOME;
  static const NEWS_DETAIL = _Paths.NEWS_DETAIL;
  static const SEARCH = _Paths.SEARCH;
  static const BOOKMARKS = _Paths.BOOKMARKS;
}

abstract class _Paths {
  _Paths._();
  static const SPLASH = '/splash';
  static const HOME = '/home';
  static const NEWS_DETAIL = '/news-detail';
  static const SEARCH = '/search';
  static const BOOKMARKS = '/bookmarks';
}
