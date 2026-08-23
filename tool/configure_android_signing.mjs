import { existsSync, readFileSync, writeFileSync } from 'node:fs';

const path = 'android/app/build.gradle.kts';
if (!existsSync(path)) {
  throw new Error('No existe android/app/build.gradle.kts.');
}

let source = readFileSync(path, 'utf8');
if (!source.includes('val releaseKeystoreProperties')) {
  source = `import java.io.FileInputStream\nimport java.util.Properties\n\n${source}`;
  source = source.replace(
    /android\s*\{/,
    `val releaseKeystoreProperties = Properties()\n` +
      `val releaseKeystorePropertiesFile = rootProject.file("key.properties")\n` +
      `releaseKeystoreProperties.load(FileInputStream(releaseKeystorePropertiesFile))\n\n` +
      `android {`,
  );
  source = source.replace(
    /\n\s*buildTypes\s*\{/,
    `\n    signingConfigs {\n` +
      `        create("release") {\n` +
      `            keyAlias = releaseKeystoreProperties["keyAlias"] as String\n` +
      `            keyPassword = releaseKeystoreProperties["keyPassword"] as String\n` +
      `            storeFile = file(releaseKeystoreProperties["storeFile"] as String)\n` +
      `            storePassword = releaseKeystoreProperties["storePassword"] as String\n` +
      `        }\n` +
      `    }\n\n` +
      `    buildTypes {`,
  );
}

source = source.replace(
  /signingConfig\s*=\s*signingConfigs\.getByName\("debug"\)/g,
  'signingConfig = signingConfigs.getByName("release")',
);

if (!source.includes('signingConfigs.getByName("release")')) {
  throw new Error('No fue posible configurar la firma Android de release.');
}

writeFileSync(path, source, 'utf8');
console.log('Firma Android de release configurada mediante key.properties.');
