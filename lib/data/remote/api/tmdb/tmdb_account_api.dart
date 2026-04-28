import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_account_dto.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_account_list_page_dto.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_account_state_dto.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_request_token_dto.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_session_dto.dart';

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
  Future<Map<String, dynamic>> deleteSession(
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
}
