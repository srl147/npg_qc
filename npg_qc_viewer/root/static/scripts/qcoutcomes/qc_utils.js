/*
 *
 */
/* globals $: false, define: false */
'use strict';
define(['jquery'], function () {
  var ID_PREFIX = 'rpt_key:';
  var ACTION    = 'UPDATE';

  var EXCEPTION_SPLIT = /^(.*?)( at \/)/;
  var TEST_FINAL      = /(final)$/i;
  var TEST_LIKE_ID    = /^rpt_key:/;
  var RPT_KEY_MATCH   = /^\d+:\d+$/;

  var buildIdSelector = function (id) {
    id = id.replace(/:/g, '\\3A ');
    id = id.replace(/;/g, '\\3B ');
    return '#' + id;
  };

  var buildIdSelectorFromRPT = function (rptKey) {
    return buildIdSelector(ID_PREFIX + rptKey);
  };

  var buildQuery = function (rptKeys) {
    var data = { };
    for( var i = 0; i < rptKeys.length; i++ ) {
      data[rptKeys[i]] = {};
    }
    return data;
  };

  var buildUpdateQuery = function (type, qcOutcomes, query) {
    query = query || {};
    query[type] = {};
    for ( var i = 0; i < qcOutcomes.length; i++ ) {
      query[type][qcOutcomes[i].rptKey] = { mqc_outcome: qcOutcomes[i].mqc_outcome };
    }
    query.Action = ACTION;
    return query;
  };

  var removeErrorMessages = function () {
    $("#ajax_status").empty();
  };

  var displayError = function( er ) {
    var message;
    if( typeof er === 'string' ) {
      message = er;
    } else {
      message = '' + er;
    }
    removeErrorMessages();
    $('#ajax_status').empty().append("<li class='failed_mqc'>" + message + '</li>');
  };


  var displayJqXHRError = function ( jqXHR ) {
    if ( typeof jqXHR == null || typeof jqXHR !== 'object' ) {
      throw 'Invalid parameter';
    }
    var message;
    if ( typeof jqXHR.responseJSON != null &&
         typeof jqXHR.responseJSON === 'object' &&
         typeof jqXHR.responseJSON.error === 'string' ) {
      message = $.trim(jqXHR.responseJSON.error);
      var textMatch = EXCEPTION_SPLIT.exec(message);
      if ( textMatch != null && textMatch.length > 1 ) {
        message = textMatch[1];
      }
    } else  {
      message = ( jqXHR.status || '' ) + ' ' + ( jqXHR.statusText || '');
    }
    displayError(message);
  };
  

  //This method takes an rpt_key and returns a boolean evaluating wether the key defines 
  //a lane (true) or a plex (false)
  var isLaneKey = function (rpt_key) {
    if ( typeof rpt_key !== 'string' ) {
      throw 'Invalid argument';
    }
    if ( RPT_KEY_MATCH.exec(rpt_key) != null ) {
      return true;
    } else { 
      return false; 
    }
  };

  var rptKeyFromId = function (id) {
    if ( typeof id !== 'string' ) {
      throw 'Invalid arguments';
    }
    if ( TEST_LIKE_ID.exec(id) == null ) {
      throw 'Id does not match the expected format.';
    }
    return id.substring(ID_PREFIX.length);
  };

  var allFinal = function (outcomes) {
    var okeys = Object.keys(outcomes);
    if (okeys.length == 0) {
      return false;
    }
    for ( var i = 0; i < okeys.length; i++ ) {
      if ( TEST_FINAL.exec(outcomes[okeys[i]].mqc_outcome) == null ) {
        return false;
      }
    }
    return true;
  };

  var QC_OUTCOMES = {
    ACCEPTED_PRELIMINARY: 'Accepted preliminary',
    ACCEPTED_FINAL:       'Accepted final',
    REJECTED_PRELIMINARY: 'Rejected preliminary',
    REJECTED_FINAL:       'Rejected final',
    UNDECIDED:            'Undecided',
    UNDECIDED_FINAL:      'Undecided final'
  };

  return {
    buildIdSelector: buildIdSelector,
    buildQuery: buildQuery,
    buildUpdateQuery: buildUpdateQuery,
    buildIdSelectorFromRPT: buildIdSelectorFromRPT,
    displayError: displayError,
    displayJqXHRError: displayJqXHRError,
    removeErrorMessages: removeErrorMessages,
    isLaneKey: isLaneKey,
    rptKeyFromId: rptKeyFromId,
    allFinal: allFinal,
    OUTCOMES: QC_OUTCOMES
  };
});
