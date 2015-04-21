@https://www.pivotaltracker.com/story/show/90209260 @generate_tp3_typescript
Feature: Auto import
  As a developer
  I want to import a class using its basename
  So that my code can be immune to Java refactoring.

  This feature is enabled via the tsjava section of package.json,
  by adding a property `autoImportPath` which specifies where ts-java
  will write the source file defining the autoImport function.

  Background:
    Given that ts-java has been run and autoImport.ts has compiled and linted cleanly.
    Given this boilerplate to intialize node-java:
    """
    /// <reference path='../../typings/glob/glob.d.ts' />
    /// <reference path='../../typings/node/node.d.ts' />
    /// <reference path='../../typings/power-assert/power-assert.d.ts' />
    /// <reference path='../java.d.ts' />

    import assert = require('power-assert');
    import glob = require('glob');
    import java = require('java');
    import autoImport = require('../../featureset/o/autoImport');

    function before(done: Java.Callback<void>): void {
      glob('featureset/target/**/*.jar', (err: Error, filenames: string[]): void => {
        filenames.forEach((name: string) => { java.classpath.push(name); });
        done();
      });
    }

    java.registerClient(before);

    java.ensureJvm(() => {
      var Arrays = java.import('java.util.Arrays');
      {{{ scenario_snippet }}}
    });

    """

  Scenario: Nominal
  Given the above boilerplate with following scenario snippet:
  """
  var SomeClass: Java.SomeClass.Static = autoImport('SomeClass');
  var something: Java.SomeClass = new SomeClass();
  """
  Then it compiles and lints cleanly
  And it runs and produces no output

  Scenario: Ambiguous
  Given the above boilerplate with following scenario snippet:
  """
  assert.throws(() => autoImport('Thing'), /autoImport unable to import short name/);
  """
  Then it compiles and lints cleanly
  And it runs and produces no output

  Scenario: Reserved word in package namespace
  # The package namespace java.util.function requires special handling since function is a reserved word
  # in Typescript. The typescript module name is mapped to `function_` to avoid the conflict.
  Given the above boilerplate with following scenario snippet:
  """
  var Function: Java.Function.Static = autoImport('Function');
  var func: Java.java.util.function_.Function = Function.identitySync();
  """
  Then it compiles and lints cleanly
  And it runs and produces no output

  Scenario: import via full class path
  Given the above boilerplate with following scenario snippet:
  """
  var Function: Java.Function.Static = java.import('java.util.function.Function');
  var func: Java.java.util.function_.Function = Function.identitySync();
  """
  Then it compiles and lints cleanly
  And it runs and produces no output

