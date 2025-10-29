/* auto-generated; do not edit */
import React from 'react';
import src from '../../assets/team-01.webp';
type Props = Omit<React.ImgHTMLAttributes<HTMLImageElement>, 'src' | 'alt'> & { alt?: string };
export default function Team01({ alt, ...rest }: Props) {
  return <img src={String(src)} alt={alt ?? 'Team 01'} loading="lazy" decoding="async" {...rest} />;
}
