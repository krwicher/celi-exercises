'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import Select from 'react-select';
import { supabase } from '@/lib/supabase';

type Muscle = {
  id: string;
  name: string;
};

type Option = {
  value: string;
  label: string;
};

export default function NewExercise() {
  const router = useRouter();
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [muscles, setMuscles] = useState<Option[]>([]);
  const [mobilizedMuscles, setMobilizedMuscles] = useState<Option[]>([]);
  const [stabilizedMuscles, setStabilizedMuscles] = useState<Option[]>([]);
  const [strengthenedMuscles, setStrengthenedMuscles] = useState<Option[]>([]);
  const [stretchedMuscles, setStretchedMuscles] = useState<Option[]>([]);

  useEffect(() => {
    async function fetchMuscles() {
      const { data, error } = await supabase
        .from('muscles')
        .select('*')
        .order('name');
      
      if (error) {
        console.error('Error fetching muscles:', error);
        return;
      }
      
      setMuscles(data.map(muscle => ({
        value: muscle.id,
        label: muscle.name
      })));
    }

    fetchMuscles();
  }, []);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    try {
      setLoading(true);
      setError(null);

      // First insert the exercise
      const { data: exercise, error: exerciseError } = await supabase
        .from('exercises')
        .insert([{ name, description }])
        .select()
        .single();

      if (exerciseError) throw exerciseError;

      // Then insert the muscle relationships
      const muscleRelationships = [
        ...mobilizedMuscles.map(muscle => ({
          exercise_id: exercise.id,
          muscle_id: muscle.value,
          relationship_type: 'mobilized'
        })),
        ...stabilizedMuscles.map(muscle => ({
          exercise_id: exercise.id,
          muscle_id: muscle.value,
          relationship_type: 'stabilized'
        })),
        ...strengthenedMuscles.map(muscle => ({
          exercise_id: exercise.id,
          muscle_id: muscle.value,
          relationship_type: 'strengthened'
        })),
        ...stretchedMuscles.map(muscle => ({
          exercise_id: exercise.id,
          muscle_id: muscle.value,
          relationship_type: 'stretched'
        }))
      ];

      if (muscleRelationships.length > 0) {
        const { error: relationshipError } = await supabase
          .from('exercise_muscles')
          .insert(muscleRelationships);

        if (relationshipError) throw relationshipError;
      }

      router.push('/');
    } catch (e: any) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  }

  const selectStyles = {
    control: (base: any) => ({
      ...base,
      borderColor: '#D1D5DB',
      '&:hover': {
        borderColor: '#9CA3AF'
      }
    }),
    option: (base: any, state: { isSelected: boolean }) => ({
      ...base,
      backgroundColor: state.isSelected ? '#4F46E5' : base.backgroundColor,
      '&:hover': {
        backgroundColor: state.isSelected ? '#4F46E5' : '#F3F4F6'
      }
    })
  };

  return (
    <div className="px-4 sm:px-6 lg:px-8">
      <div className="sm:flex sm:items-center">
        <div className="sm:flex-auto">
          <h1 className="text-2xl font-semibold text-gray-900">Add New Exercise</h1>
          <p className="mt-2 text-sm text-gray-700">
            Create a new exercise with detailed information.
          </p>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="mt-8 space-y-6">
        {error && (
          <div className="rounded-md bg-red-50 p-4">
            <div className="flex">
              <div className="ml-3">
                <h3 className="text-sm font-medium text-red-800">Error</h3>
                <div className="mt-2 text-sm text-red-700">
                  <p>{error}</p>
                </div>
              </div>
            </div>
          </div>
        )}

        <div className="space-y-4">
          <div>
            <label htmlFor="name" className="block text-sm font-medium text-gray-700">
              Exercise Name
            </label>
            <div className="mt-1">
              <input
                type="text"
                name="name"
                id="name"
                value={name}
                onChange={(e) => setName(e.target.value)}
                required
                className="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                placeholder="e.g., Push-ups"
              />
            </div>
          </div>

          <div>
            <label htmlFor="description" className="block text-sm font-medium text-gray-700">
              Description
            </label>
            <div className="mt-1">
              <div className="mb-2 text-sm text-gray-500">
                Include the following information:
                <ul className="list-disc pl-5 mt-1 space-y-1">
                  <li>Starting position</li>
                  <li>Movement instructions</li>
                  <li>Breathing pattern</li>
                  <li>Common mistakes to avoid</li>
                  <li>Modifications for different skill levels</li>
                  <li>Safety considerations</li>
                </ul>
              </div>
              <textarea
                id="description"
                name="description"
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                rows={12}
                required
                className="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                placeholder={`Example format:

Starting Position:
- Stand with feet shoulder-width apart
- Keep chest up and core engaged

Movement:
1. Begin by...
2. Next, slowly...
3. Return to starting position

Breathing:
- Inhale during...
- Exhale when...

Common Mistakes:
- Avoid...
- Watch out for...

Modifications:
Beginner: ...
Advanced: ...

Safety Notes:
- Ensure...
- If you experience...`}
              />
            </div>
          </div>

          <div>
            <label htmlFor="mobilized-muscles" className="block text-sm font-medium text-gray-700">
              Mobilized Muscles
            </label>
            <div className="mt-1">
              <Select
                id="mobilized-muscles"
                isMulti
                options={muscles}
                value={mobilizedMuscles}
                onChange={(selected) => setMobilizedMuscles(selected as Option[])}
                className="basic-multi-select"
                classNamePrefix="select"
                styles={selectStyles}
                placeholder="Select muscles..."
              />
            </div>
          </div>

          <div>
            <label htmlFor="stabilized-muscles" className="block text-sm font-medium text-gray-700">
              Stabilized Muscles
            </label>
            <div className="mt-1">
              <Select
                id="stabilized-muscles"
                isMulti
                options={muscles}
                value={stabilizedMuscles}
                onChange={(selected) => setStabilizedMuscles(selected as Option[])}
                className="basic-multi-select"
                classNamePrefix="select"
                styles={selectStyles}
                placeholder="Select muscles..."
              />
            </div>
          </div>

          <div>
            <label htmlFor="strengthened-muscles" className="block text-sm font-medium text-gray-700">
              Strengthened Muscles
            </label>
            <div className="mt-1">
              <Select
                id="strengthened-muscles"
                isMulti
                options={muscles}
                value={strengthenedMuscles}
                onChange={(selected) => setStrengthenedMuscles(selected as Option[])}
                className="basic-multi-select"
                classNamePrefix="select"
                styles={selectStyles}
                placeholder="Select muscles..."
              />
            </div>
          </div>

          <div>
            <label htmlFor="stretched-muscles" className="block text-sm font-medium text-gray-700">
              Stretched Muscles
            </label>
            <div className="mt-1">
              <Select
                id="stretched-muscles"
                isMulti
                options={muscles}
                value={stretchedMuscles}
                onChange={(selected) => setStretchedMuscles(selected as Option[])}
                className="basic-multi-select"
                classNamePrefix="select"
                styles={selectStyles}
                placeholder="Select muscles..."
              />
            </div>
          </div>
        </div>

        <div className="flex justify-end gap-4">
          <Link
            href="/"
            className="rounded-md border border-gray-300 bg-white py-2 px-4 text-sm font-medium text-gray-700 shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
          >
            Cancel
          </Link>
          <button
            type="submit"
            disabled={loading}
            className="inline-flex justify-center rounded-md border border-transparent bg-indigo-600 py-2 px-4 text-sm font-medium text-white shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {loading ? 'Saving...' : 'Save Exercise'}
          </button>
        </div>
      </form>
    </div>
  );
}