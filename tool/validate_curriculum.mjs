import { readFileSync } from 'node:fs';

const path = 'assets/content/curriculum.json';
const curriculum = JSON.parse(readFileSync(path, 'utf8'));
const errors = [];
const levels = curriculum.levels ?? [];
const lessons = levels.flatMap((level) => level.lessons ?? []);

if (levels.length !== 8) errors.push(`Se esperaban 8 niveles y hay ${levels.length}.`);
if (lessons.length !== 24) errors.push(`Se esperaban 24 clases y hay ${lessons.length}.`);

const levelIds = new Set();
const lessonIds = new Set();
const orders = new Set();

for (const level of levels) {
  if (!level.id || levelIds.has(level.id)) errors.push(`Nivel repetido o sin id: ${level.id}.`);
  levelIds.add(level.id);
  if (level.lessons?.length !== 3) errors.push(`${level.id} debe tener 3 clases.`);
}

for (const lesson of lessons) {
  if (!lesson.id || lessonIds.has(lesson.id)) errors.push(`Clase repetida o sin id: ${lesson.id}.`);
  lessonIds.add(lesson.id);
  if (orders.has(lesson.order)) errors.push(`Orden repetido: ${lesson.order}.`);
  orders.add(lesson.order);

  if (lesson.activities?.length !== 3) errors.push(`${lesson.id} debe tener 3 actividades.`);
  const activityMinutes = (lesson.activities ?? []).reduce(
    (sum, activity) => sum + (activity.minutes ?? 0),
    0,
  );
  if (activityMinutes !== lesson.durationMinutes) {
    errors.push(`${lesson.id}: actividades=${activityMinutes}, clase=${lesson.durationMinutes}.`);
  }

  for (const field of [
    'title',
    'objective',
    'why',
    'diagram',
    'challenge',
    'safety',
    'accessibility',
    'teacherTip',
  ]) {
    if (typeof lesson[field] !== 'string' || !lesson[field].trim()) {
      errors.push(`${lesson.id} no tiene ${field}.`);
    }
  }
}

for (let order = 1; order <= 24; order += 1) {
  if (!orders.has(order)) errors.push(`Falta el orden ${order}.`);
}

if (errors.length) {
  console.error(`Currículo inválido:\n- ${errors.join('\n- ')}`);
  process.exit(1);
}

console.log(`Currículo válido: ${levels.length} niveles, ${lessons.length} clases y ${lessons.length * 3} actividades.`);
