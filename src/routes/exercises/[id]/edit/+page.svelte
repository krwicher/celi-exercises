<script lang="ts">
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { supabase } from '$lib/supabase';

  let name = '';
  let description = '';
  let loading = true;
  let error: string | null = null;

  onMount(() => {
    fetchExercise();
  });

  async function fetchExercise() {
    try {
      const { data: exercise, error: exerciseError } = await supabase
        .from('exercises')
        .select('*')
        .eq('id', $page.params.id)
        .single();

      if (exerciseError) throw exerciseError;
      if (!exercise) throw new Error('Exercise not found');

      name = exercise.name;
      description = exercise.description;
    } catch (e: any) {
      error = e.message;
    } finally {
      loading = false;
    }
  }

  async function handleSubmit() {
    try {
      loading = true;
      error = null;

      const { error: updateError } = await supabase
        .from('exercises')
        .update({ name, description })
        .eq('id', $page.params.id);

      if (updateError) throw updateError;

      await goto('/');
    } catch (e: any) {
      error = e.message;
    } finally {
      loading = false;
    }
  }
</script>

<div class="px-4 sm:px-6 lg:px-8">
  <div class="sm:flex sm:items-center">
    <div class="sm:flex-auto">
      <h1 class="text-2xl font-semibold text-gray-900">Edit Exercise</h1>
      <p class="mt-2 text-sm text-gray-700">
        Update exercise information.
      </p>
    </div>
  </div>

  {#if loading}
    <div class="p-4">Loading...</div>
  {:else}
    <form on:submit|preventDefault={handleSubmit} class="mt-8 space-y-6">
      {#if error}
        <div class="rounded-md bg-red-50 p-4">
          <div class="flex">
            <div class="ml-3">
              <h3 class="text-sm font-medium text-red-800">Error</h3>
              <div class="mt-2 text-sm text-red-700">
                <p>{error}</p>
              </div>
            </div>
          </div>
        </div>
      {/if}

      <div class="space-y-4">
        <div>
          <label for="name" class="block text-sm font-medium text-gray-700">
            Exercise Name
          </label>
          <div class="mt-1">
            <input
              type="text"
              name="name"
              id="name"
              bind:value={name}
              required
              class="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
              placeholder="e.g., Push-ups"
            />
          </div>
        </div>

        <div>
          <label for="description" class="block text-sm font-medium text-gray-700">
            Description
          </label>
          <div class="mt-1">
            <textarea
              id="description"
              name="description"
              bind:value={description}
              rows="4"
              required
              class="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
              placeholder="Describe how to perform the exercise..."
            />
          </div>
        </div>
      </div>

      <div class="flex justify-end gap-4">
        <a
          href="/"
          class="rounded-md border border-gray-300 bg-white py-2 px-4 text-sm font-medium text-gray-700 shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
        >
          Cancel
        </a>
        <button
          type="submit"
          disabled={loading}
          class="inline-flex justify-center rounded-md border border-transparent bg-indigo-600 py-2 px-4 text-sm font-medium text-white shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {loading ? 'Saving...' : 'Save Changes'}
        </button>
      </div>
    </form>
  {/if}
</div>