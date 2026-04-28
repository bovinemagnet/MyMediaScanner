import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_account_dto.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_account_list_page_dto.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_account_lists_page_dto.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_account_state_dto.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_list_create_response_dto.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_request_token_dto.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_session_dto.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_status_response_dto.dart';

part 'tmdb_account_api.g.dart';

/// TMDB v3 user-authentication and account endpoints.
///
/// Distinct from the read-only [TmdbApi] so that account-write paths
/// in slice 2 cannot leak into metadata lookups.
@RestApi()
abstract class TmdbAccountApi {
  factory TmdbAccountApi(Dio dio) = _TmdbAccountApi;

  // ── Auth lifecycle ────────────────────────────────────────────

  @GET('/authentication/token/new')
  Future<TmdbRequestTokenDto> createRequestToken();

  @POST('/authentication/session/new')
  Future<TmdbSessionDto> createSession(
    @Body() Map<String, dynamic> body, // {'request_token': '...'}
  );

  @DELETE('/authentication/session')
  Future<void> deleteSession(
    @Body() Map<String, dynamic> body, // {'session_id': '...'}
  );

  // ── Account ───────────────────────────────────────────────────

  @GET('/account')
  Future<TmdbAccountDto> getAccount(
    @Query('session_id') String sessionId,
  );

  // ── Account-state for a specific title ────────────────────────

  @GET('/movie/{id}/account_states')
  Future<TmdbAccountStateDto> getMovieAccountState(
    @Path('id') int id,
    @Query('session_id') String sessionId,
  );

  @GET('/tv/{id}/account_states')
  Future<TmdbAccountStateDto> getTvAccountState(
    @Path('id') int id,
    @Query('session_id') String sessionId,
  );

  // ── Buckets ───────────────────────────────────────────────────

  @GET('/account/{accountId}/rated/movies')
  Future<TmdbAccountListPageDto> getRatedMovies(
    @Path('accountId') int accountId,
    @Query('session_id') String sessionId, {
    @Query('page') int page = 1,
  });

  @GET('/account/{accountId}/rated/tv')
  Future<TmdbAccountListPageDto> getRatedTv(
    @Path('accountId') int accountId,
    @Query('session_id') String sessionId, {
    @Query('page') int page = 1,
  });

  @GET('/account/{accountId}/watchlist/movies')
  Future<TmdbAccountListPageDto> getWatchlistMovies(
    @Path('accountId') int accountId,
    @Query('session_id') String sessionId, {
    @Query('page') int page = 1,
  });

  @GET('/account/{accountId}/watchlist/tv')
  Future<TmdbAccountListPageDto> getWatchlistTv(
    @Path('accountId') int accountId,
    @Query('session_id') String sessionId, {
    @Query('page') int page = 1,
  });

  @GET('/account/{accountId}/favorite/movies')
  Future<TmdbAccountListPageDto> getFavoriteMovies(
    @Path('accountId') int accountId,
    @Query('session_id') String sessionId, {
    @Query('page') int page = 1,
  });

  @GET('/account/{accountId}/favorite/tv')
  Future<TmdbAccountListPageDto> getFavoriteTv(
    @Path('accountId') int accountId,
    @Query('session_id') String sessionId, {
    @Query('page') int page = 1,
  });

  // ── Rating push (slice 2) ─────────────────────────────────────

  @POST('/movie/{id}/rating')
  Future<TmdbStatusResponseDto> addMovieRating(
    @Path('id') int id,
    @Query('session_id') String sessionId,
    @Body() Map<String, dynamic> body, // {'value': <0.5..10>}
  );

  @POST('/tv/{id}/rating')
  Future<TmdbStatusResponseDto> addTvRating(
    @Path('id') int id,
    @Query('session_id') String sessionId,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/movie/{id}/rating')
  Future<TmdbStatusResponseDto> removeMovieRating(
    @Path('id') int id,
    @Query('session_id') String sessionId,
  );

  @DELETE('/tv/{id}/rating')
  Future<TmdbStatusResponseDto> removeTvRating(
    @Path('id') int id,
    @Query('session_id') String sessionId,
  );

  // ── Watchlist / Favourite push (slice 2) ──────────────────────

  @POST('/account/{accountId}/watchlist')
  Future<TmdbStatusResponseDto> setWatchlist(
    @Path('accountId') int accountId,
    @Query('session_id') String sessionId,
    @Body() Map<String, dynamic> body,
    // body: {'media_type': 'movie'|'tv', 'media_id': <int>, 'watchlist': bool}
  );

  @POST('/account/{accountId}/favorite')
  Future<TmdbStatusResponseDto> setFavorite(
    @Path('accountId') int accountId,
    @Query('session_id') String sessionId,
    @Body() Map<String, dynamic> body,
    // body: {'media_type': 'movie'|'tv', 'media_id': <int>, 'favorite': bool}
  );

  // ── List management (slice 2 — movies only) ───────────────────

  @GET('/account/{accountId}/lists')
  Future<TmdbAccountListsPageDto> getAccountLists(
    @Path('accountId') int accountId,
    @Query('session_id') String sessionId, {
    @Query('page') int page = 1,
  });

  @POST('/list')
  Future<TmdbListCreateResponseDto> createList(
    @Query('session_id') String sessionId,
    @Body() Map<String, dynamic> body,
    // body: {'name': '...', 'description': '...', 'language': 'en'}
  );

  @POST('/list/{id}/add_item')
  Future<TmdbStatusResponseDto> addItemToList(
    @Path('id') int id,
    @Query('session_id') String sessionId,
    @Body() Map<String, dynamic> body, // {'media_id': <tmdb_id>}
  );

  @POST('/list/{id}/remove_item')
  Future<TmdbStatusResponseDto> removeItemFromList(
    @Path('id') int id,
    @Query('session_id') String sessionId,
    @Body() Map<String, dynamic> body, // {'media_id': <tmdb_id>}
  );
}
