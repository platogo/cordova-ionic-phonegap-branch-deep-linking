"use strict";

(function() {
  // properties
  


  const nodeDependencies = require("../npm/downloadNpmDependencies.js");

  // entry
  module.exports = run;

  // builds before plugin install hooks
  function run(context) {
    nodeDependencies.install(context);
  }
})();
