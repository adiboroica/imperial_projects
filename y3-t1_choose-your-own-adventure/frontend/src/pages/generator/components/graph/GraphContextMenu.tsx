/**
 * GraphContextMenu — right-click menu shown over a node.
 *
 * Presentational: caller controls visibility via `position`. Items are
 * conditionally rendered based on which callbacks are supplied.
 */

import { Menu, Paper } from "@mantine/core";
import { useEffect, useRef } from "react";

type Props = {
  position: { x: number; y: number } | null;
  onClose: () => void;
  onDelete?: () => void;
  onDisconnect?: () => void;
  onExpand?: () => void;
};

const GraphContextMenu = ({
  position,
  onClose,
  onDelete,
  onDisconnect,
  onExpand,
}: Props) => {
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!position) return;
    const handler = (e: MouseEvent) => {
      if (ref.current && !ref.current.contains(e.target as Node)) onClose();
    };
    document.addEventListener("mousedown", handler);
    return () => document.removeEventListener("mousedown", handler);
  }, [position, onClose]);

  if (!position) return null;

  return (
    <div
      ref={ref}
      style={{
        position: "fixed",
        top: position.y,
        left: position.x,
        zIndex: 1000,
      }}
    >
      <Paper withBorder shadow="md" radius="sm">
        <Menu opened width={180} closeOnItemClick={false}>
          <Menu.Dropdown>
            {onExpand && (
              <Menu.Item onClick={() => { onExpand(); onClose(); }}>
                Expand
              </Menu.Item>
            )}
            {onDisconnect && (
              <Menu.Item onClick={() => { onDisconnect(); onClose(); }}>
                Disconnect
              </Menu.Item>
            )}
            {onDelete && (
              <Menu.Item
                color="red"
                onClick={() => { onDelete(); onClose(); }}
              >
                Delete
              </Menu.Item>
            )}
          </Menu.Dropdown>
        </Menu>
      </Paper>
    </div>
  );
};

export default GraphContextMenu;
