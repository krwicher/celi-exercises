<script lang="ts">
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabase';

  type Exercise = {
    id: string;
    name: string;
    description: string;
    created_at: string;
  };

  let exercises: Exercise[] = [];
  let loading = true;
  let error: string | null = null;

  onMount(() => {
    fetchExercises();
  });

  async function fetchExercises() {
    try {
      const { data, error: supabaseError } = await supabase
        .from('exercises')
        .select('*')
        .order('created_at', { ascending: false });

      if (supabaseError) throw supabaseError;
      exercises = data || [];
    } catch (e: any) {
      error = e.message;
    } finally {
      loading = false;
    }
  }

  async function handleDelete(id: string) {
    if (!confirm('Are you sure you want to delete this exercise?')) return;

    try {
      const { error: deleteError } = await supabase
        .from('exercises')
        .delete()
        .eq('id', id);

      if (deleteError) throw deleteError;
      
      // Refresh the list
      await fetchExercises();
    } catch (e: any) {
      alert('Error deleting exercise: ' + e.message);
    }
  }
</script>

<div class="px-4 sm:px-6 lg:px-8">
  <div class="sm:flex sm:items-center">
    <div class="sm:flex-auto">
      <h1 class="text-2xl font-semibold text-gray-900">Exercises</h1>
      <p class="mt-2 text-sm text-gray-700">
        A comprehensive list of exercises with detailed information about muscles involved.
      </p>
    </div>
    <div class="mt-4 sm:mt-0 sm:ml-16 sm:flex-none">
      <a
        href="/exercises/new"
        class="inline-flex items-center justify-center rounded-md border border-transparent bg-indigo-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 sm:w-auto"
      >
        Add exercise
      </a>
    </div>
  </div>

  {#if error}
    <div class="mt-4 rounded-md bg-red-50 p-4">
      <div class="text-sm text-red-700">{error}</div>
    </div>
  {/if}

  {#if loading}
    <div class="p-4">Loading...</div>
  {:else}
    <div class="mt-8 flex flex-col">
      <div class="-mx-4 -my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
        <div class="inline-block min-w-full py-2 align-middle md:px-6 lg:px-8">
          <div class="overflow-hidden shadow ring-1 ring-black ring-opacity-5 md:rounded-lg">
            <table class="min-w-full divide-y divide-gray-300">
              <thead class="bg-gray-50">
                <tr>
                  <th scope="col" class="py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-900 sm:pl-6">
                    Name
                  </th>
                  <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                    Description
                  </th>
                  <th scope="col" class="relative py-3.5 pl-3 pr-4 sm:pr-6">
                    <span class="sr-only">Actions</span>
                  </th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-200 bg-white">
                {#each exercises as exercise (exercise.id)}
                  <tr>
                    <td class="whitespace-nowrap py-4 pl-4 pr-3 text-sm font-medium text-gray-900 sm:pl-6">
                      {exercise.name}
                    </td>
                    <td class="px-3 py-4 text-sm text-gray-500">
                      {exercise.description.length > 100
                        ? `${exercise.description.substring(0, 100)}...`
                        : exercise.description}
                    </td>
                    <td class="relative whitespace-nowrap py-4 pl-3 pr-4 text-right text-sm font-medium sm:pr-6">
                      <a
                        href={`/exercises/${exercise.id}/edit`}
                        class="text-indigo-600 hover:text-indigo-900 mr-4"
                      >
                        Edit
                      </a>
                      <button
                        on:click={() => handleDelete(exercise.id)}
                        class="text-red-600 hover:text-red-900"
                      >
                        Delete
                      </button>
                    </td>
                  </tr>
                {/each}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  {/if}
</div>