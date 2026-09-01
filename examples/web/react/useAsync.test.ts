import { act, renderHook, waitFor } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { useAsync } from './useAsync';

describe('useAsync', () => {
  it('resolves data and clears loading', async () => {
    const fn = vi.fn(async (_signal: AbortSignal) => 42);

    const { result } = renderHook(() => useAsync(fn, []));
    expect(result.current.isLoading).toBe(true);

    await waitFor(() => expect(result.current.isLoading).toBe(false));
    expect(result.current.data).toBe(42);
    expect(result.current.error).toBeNull();
  });

  it('surfaces errors instead of swallowing them', async () => {
    const fn = vi.fn(async (_signal: AbortSignal) => {
      throw new Error('boom');
    });

    const { result } = renderHook(() => useAsync(fn, []));
    await waitFor(() => expect(result.current.isLoading).toBe(false));

    expect(result.current.data).toBeNull();
    expect(result.current.error?.message).toBe('boom');
  });

  it('aborts the in-flight request on unmount', async () => {
    let aborted = false;
    const fn = (signal: AbortSignal) =>
      new Promise<number>((_resolve, reject) => {
        signal.addEventListener('abort', () => {
          aborted = true;
          reject(new DOMException('Aborted', 'AbortError'));
        });
      });

    const { result, unmount } = renderHook(() => useAsync(fn, []));
    await act(async () => unmount());
    expect(aborted).toBe(true);
    expect(result.current.error).toBeNull();
  });
});
