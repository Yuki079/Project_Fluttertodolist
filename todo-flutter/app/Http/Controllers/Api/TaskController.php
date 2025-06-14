<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Task;

class TaskController extends Controller
{
    public function index()
    {
        return Task::all();
    }

    public function store(Request $request)
    {
        $request->validate([
            'title' => 'required|string',
            'priority' => 'required|in:low,medium,high',
            'due_date' => 'required|date',
        ]);

        $task = Task::create([
            'title'     => $request->title,
            'priority'  => $request->priority,
            'due_date'  => $request->due_date,
            'is_done'   => false,
        ]);

        return response()->json($task, 201);
    }

    public function update(Request $request, $id)
    {
        $task = Task::findOrFail($id);

        $task->update($request->only([
            'title',
            'priority',
            'due_date',
            'is_done',
        ]));

        return response()->json($task);
    }

    public function destroy($id)
    {
        Task::destroy($id);

        return response()->json(null, 204);
    }
}
